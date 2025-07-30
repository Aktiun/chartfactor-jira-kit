#!/usr/bin/env bash
set -euo pipefail

# Load environment variables from .env if present ───
if [[ -f .env ]]; then
  # export every var in .env
  set -o allexport
  source .env
  set +o allexport
fi

# Sanity checks for input variables
: "${JIRA_DOMAIN:?Need to set JIRA_DOMAIN in .env}"
: "${JIRA_API_TOKEN:?Need to set JIRA_API_TOKEN in .env}"
: "${JIRA_EMAIL:?Need to set JIRA_EMAIL in .env}"
: "${JIRA_PROJECTS:?Need to set JIRA_PROJECTS in .env}"
: "${JIRA_START_DATE:?Need to set JIRA_START_DATE in .env}"

: "${BQ_PROJECT_ID:?Need to set BQ_PROJECT_ID in .env}"
: "${BQ_DATASET_ID:?Need to set BQ_DATASET_ID in .env}"
: "${BQ_DATASET_LOCATION:?Need to set BQ_DATASET_LOCATION in .env}"
: "${BQ_CREDS_PATH:?Need to set BQ_CREDS_PATH in .env}"


# Deploy Airbyte locally (only needs Docker up & running)
abctl local install --values ./values.yaml

# Get the generated client-id/secret
creds=$(abctl local credentials)
export NO_COLOR=1
creds=$(abctl local credentials)

# Extract clientId and clientSecret fields:
clientId=$(echo "$creds" \
  | sed -n -E 's/.*Client-Id:[[:space:]]*//p')

clientSecret=$(echo "$creds" \
  | sed -n -E 's/.*Client-Secret:[[:space:]]*//p')

# Exchange for a JWT token (credentials‐grant)
token_response=$(curl -s -X POST http://localhost:8000/api/v1/applications/token \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
        --arg ci "$clientId" \
        --arg cs "$clientSecret" \
        '{client_id: $ci, client_secret: $cs}')" )

# Extract the Bearer token
accessToken=$(jq -r .access_token <<<"$token_response")

# Verify
# echo "Got Airbyte token: $accessToken"

# Obtain workspace id
workspaceId=$(
  curl -s \
    -H "Authorization: Bearer $accessToken" \
    "http://localhost:8000/api/public/v1/workspaces?includeDeleted=false" \
  | jq -r '.data[] 
           | select(.name=="Default Workspace") 
           | .workspaceId'
)

# List all source definitions (private API)
defs=$(
  curl -s -X POST http://localhost:8000/api/v1/source_definitions/list \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $accessToken" \
    -d '{}'
)

# Extract the Jira source definition Id
jiraDefId=$(
  jq -r '
    .sourceDefinitions[]
    | select(.name=="Jira")
    | .sourceDefinitionId
  ' <<<"$defs"
)

echo "JIRA_DEF_ID is: $jiraDefId"

# List all destination definitions (private API)
dest_defs=$(
  curl -s -X POST http://localhost:8000/api/v1/destination_definitions/list \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $accessToken" \
    -d '{}'
)

# Extract just the Bigquery definition ID
bqDefId=$(
    jq -r '
    .destinationDefinitions[] 
    | select(.name=="BigQuery") 
    | .destinationDefinitionId
    ' <<<"$dest_defs"
)

echo "BIGQUERY_DEF_ID is: $bqDefId"

# ─── Build a JSON-array string from $JIRA_PROJECTS ───
#   "PROJ1,PROJ2,PROJ3" → ["PROJ1","PROJ2","PROJ3"]
projects_json=$(printf '"%s",' $(echo "$JIRA_PROJECTS" | sed 's/,/","/g'))
projects_json="[${projects_json%,}]"

#
# Creating or reusing the Jira Source
#

echo "🔍 Checking for existing Jira Source…"
existing_source_id=$(
  curl -s -X POST http://localhost:8000/api/v1/sources/list \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $accessToken" \
    -d "{\"workspaceId\":\"$workspaceId\"}" \
  | jq -r '.sources[] 
           | select(.name=="Jira Source") 
           | .sourceId // empty'
)

if [[ -n "$existing_source_id" ]]; then
  sourceId=$existing_source_id
  echo "✔️ Found existing Jira Source (sourceId=$sourceId)"
else
  echo "➕ Jira Source not found—creating a new one…"
  response=$(
    curl -s -X POST http://localhost:8000/api/v1/sources/create \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $accessToken" \
      -d "{
        \"name\": \"Jira Source\",
        \"workspaceId\": \"$workspaceId\",
        \"sourceDefinitionId\": \"$jiraDefId\",
        \"connectionConfiguration\": {
          \"domain\":      \"$JIRA_DOMAIN\",
          \"email\":       \"$JIRA_EMAIL\",
          \"api_token\":   \"$JIRA_API_TOKEN\",
          \"projects\":    $projects_json,
          \"start_date\":  \"$JIRA_START_DATE\"
        }
      }"
  )
  sourceId=$(jq -r .sourceId <<<"$response")
  echo "✅ Created Jira Source (sourceId=$sourceId)"
fi

#
# Creating BigQuery Destination
#
bq_creds_json=$(jq -Rs . "$BQ_CREDS_PATH")

bq_resp=$(
  curl -s -X POST http://localhost:8000/api/v1/destinations/create \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $accessToken" \
    -d "{
      \"name\": \"BigQuery Dest\",
      \"workspaceId\": \"$workspaceId\",
      \"destinationDefinitionId\": \"$bqDefId\",
      \"connectionConfiguration\": {
        \"project_id\":        \"$BQ_PROJECT_ID\",
        \"dataset_id\":        \"$BQ_DATASET_ID\",
        \"dataset_location\":  \"$BQ_DATASET_LOCATION\",
        \"credentials_json\":  $bq_creds_json
      }
    }"
)
destId=$(jq -r .destinationId <<<"$bq_resp")

#
# Creating the Connection
#

# 1. Select only the streams we are using for the demo
sync_catalog=$(
  curl -s -X POST http://localhost:8000/api/v1/sources/discover_schema \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $accessToken" \
    -d "{\"sourceId\":\"$sourceId\"}" \
  | jq -c '
      .catalog.streams
      | map(select(
          .stream.name == "issue_fields"    or
          .stream.name == "issue_worklogs"  or
          .stream.name == "issues"          or
          .stream.name == "projects"        or
          .stream.name == "users"
        ))
      | map(
          .stream.jsonSchema |= walk(if type=="object" then del(.description) else . end)
          | .config.selected  = true
          | .config.suggested = true
        )
      | { streams: . }
    '
)

# 2. Create the connection
create_resp=$(
  curl -s -X POST http://localhost:8000/api/v1/connections/create \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $accessToken" \
    -d @- <<EOF
{
  "name":         "Jira → BigQuery (filtered)",
  "workspaceId":  "$workspaceId",
  "sourceId":      "$sourceId",
  "destinationId": "$destId",
  "syncCatalog":   $sync_catalog,
  "status":        "active",
  "schedule": {
    "timeUnit": "hours",
    "units":    24
  }
}
EOF
)

connectionId=$(jq -r '.connectionId' <<<"$create_resp")
echo "✅ Created connection with ID: $connectionId"

#
# Updating custom SQL in CFS file with the JIRA_DOMAIN to be rendered as part of clickable URLs in tables
#

# Paths
infile="JIRA Worklogs Analysis Template - BQ.cfs"
outfile="JIRA Worklogs Analysis - BQ.cfs"

# Sanity check
if [[ ! -f "$infile" ]]; then
  echo "Error: input file '$infile' not found" >&2
  exit 1
fi

# Perform the replacement and write to the new file
sed \
  -e "s|\${JIRA_DOMAIN}|${JIRA_DOMAIN}|g" \
  -e "s|\${BQ_PROJECT_ID}|${BQ_PROJECT_ID}|g" \
  -e "s|\${BQ_DATASET_ID}|${BQ_DATASET_ID}|g" \
  "$infile" > "$outfile"

echo "✅ Created '$outfile' with JIRA_DOMAIN=${JIRA_DOMAIN}"

#
# Waiting for the source tables to appear
#

echo "⏳ Waiting for issue_worklogs and issues tables…"

# maximum retries & sleep interval
max_retries=96   # e.g. 96×5s = 8 minutes max wait
interval=5       # seconds

for ((i=1; i<=max_retries; i++)); do
  # TODO: Needs to check in BQ, not PG
  exists_worklogs=$(
    docker compose exec -T db psql -U "$PG_USER" -d "$PG_DB" -tAc \
      "SELECT 1 FROM information_schema.tables 
         WHERE table_schema = '$PG_SCHEMA'
           AND table_name   = 'issue_worklogs';"
  )

  exists_issues=$(
    docker compose exec -T db psql -U "$PG_USER" -d "$PG_DB" -tAc \
      "SELECT 1 FROM information_schema.tables 
         WHERE table_schema = '$PG_SCHEMA'
           AND table_name   = 'issues';"
  )

  if [[ "$exists_worklogs" == "1" && "$exists_issues" == "1" ]]; then
    echo "✅ Source tables are ready."
    break
  fi

  echo "…not ready yet (attempt $i/$max_retries), sleeping ${interval}s"
  sleep $interval

  if (( i == max_retries )); then
    echo "❌ timed out waiting for tables" >&2
    exit 1
  fi
done
