# ChartFactor JIRA kit

This repository allows you to connect to JIRA so that you can analyze tickets and worklogs using ChartFactor. 

Note that this connector uses Postgres or the BigQuery emulator as a data warehouse for a lower onboarding barrier and no billing or quotas.  Consider using these data engines as a destination for small data volumes (e.g. less than 10GB) or for testing purposes. For larger data volumes and for full governance, we recommend using a data warehouse like such as Google BigQuery.

# Steps

Execute the command below. Please make sure ports 8000 and 5433 are available in your local computer. 

```commandline
airbyte-jira-pg.sh
```

