# ChartFactor JIRA Connector Kit

This repository allows you to analyze JIRA tickets and worklogs using ChartFactor. If you would like to visualize the time your team is logging into their JIRA tickets without having to spend hundreds of dollars per month in Tempo licensing fees, then you should read on.

![JIRA Worklogs App](https://github.com/Aktiun/chartfactor-jira-kit/blob/main/JIRA%20App.gif)

This connector includes two options for the data warehouse: 

* Postgres: Lower onboarding barrier since it is included as a docker compose service. Consider using this data engine as a destination for small data volumes (e.g. less than 10GB) or for testing purposes.
* BigQuery: Recommended for larger data volumes and for full governance. You can easily switch to this option after proving value with the Postgres option.

# Pre-requisites

You need to have Docker Desktop on your machine. 

# Steps

## 1. Setting up abctl 

abctl is Airbyte's command-line tool for deploying and managing Airbyte. Airbyte is an open-source data integration platform that helps teams move data from various sources into data warehouses. 

If you are using a Mac, use Homebrew to install Airbyte's abctl.

a. Install Homebrew, if you haven't already.

b. Run the following commands after you install Homebrew.

```commandline
brew tap airbytehq/tap
brew install abctl
```

c. Keep abctl up to date with Homebrew, too.

```commandline
brew upgrade abctl
```

Please refer to Airbyte's [Quickstart documentation - Install abctl](https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart#part-2-install-abctl) to install abctl if you are using Linux or Windows.

## 2. Run the connection setup script - Postgres

This script performs the following actions:

* Deploys Airbyte locally.
* Starts Postgres and the Postgres-REST API
* Creates the Airbyte source, destination, and connection configurations to populate the Postgres "jira" schema with Jira issues and worklogs.
* Prepares the "JIRA Worklogs Analysis - PG.cfs" file that you can import into ChartFactor Studio. This file contains the visualization configurations.

To run the script, follow the steps below:

a. Pull the [chartfactor-jira-kit](https://github.com/Aktiun/chartfactor-jira-kit.git) repo using the command below.

```commandline
git clone https://github.com/Aktiun/chartfactor-jira-kit.git
```
b. Nagivate to the folder where the project was cloned.

c. Copy the `.env.example` file to `.env` and fill in the JIRA variables. No need to fill-in the BigQuery variables.

d. Execute the command below in your terminal window. Please make sure ports 8000 and 5433 are available in your local computer. 

```commandline
airbyte-jira-postgres.sh
```

Note that the Airbyte installation itself may take up to 30 minutes depending on your internet connection. When it completes, your Airbyte instance opens in your web browser at http://localhost:8000. To obtain Airbyte's default credentials and set up your own password, follow these [instructions](https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart#part-4-set-up-authentication).

## 3. Visualize using ChartFactor Studio

Open [ChartFactor Studio](https://chartfactor.com/studio) and use the "Import" function located in the top-right corner of the Studio home page, to import the `JIRA Worklogs Analysis - PG.cfs` file. Then, select the imported application to open it.

You should now be able to use your Studio application to:

✔ Easily narrow down team members and time windows by dragging your mouse on top of the Heat Map, Trend, and Barchart visualizations. 

✔ Open the JIRA ticket for a specific worklog by selecting its URL on the "Work Logs" table. 

✔ Reset filters by selecting "Remove All" in the Interaction Manager section at the top right. 

✔ And if you have any questions on additional functionality, please reach out using our [Community Forum](https://community.chartfactor.com/).


# Using Google BigQuery instead of Postgres

Use BigQuery when you need governance and for larger data volumes. To set up the Google BigQuery, you need to have:

* The Google Cloud Platform (GCP) Project ID
* The location of the dataset (e.g. US)
* The BigQuery Dataset ID where tables will be replicated to
* The path to the JSON service account key file. Refer to the [Create and delete service account keys](https://cloud.google.com/iam/docs/keys-create-delete) article if you need help generating this key

Follow the steps below to set up BigQuery as the data warehouse for Jira data:

a. Nagivate to the folder where the [chartfactor-jira-kit](https://github.com/Aktiun/chartfactor-jira-kit.git) repo was cloned as described in previous sections.

b. Update the `.env` file to provide the BigQuery variables. The BigQuery variable names start with "BQ".

c. Execute the command below in your terminal window. 

```commandline
airbyte-jira-bigquery.sh
```
    
After the script completes, open [ChartFactor Studio](https://chartfactor.com/studio) and use the "Import" function located in the top-right corner of the Studio home page, to import the `JIRA Worklogs Analysis - BQ.cfs` file.

Same as when using Postgres, you should now be able to use your Studio application to:

✔ Easily narrow down team members and time windows by dragging your mouse on top of the Heat Map, Trend, and Barchart visualizations. 

✔ Open the JIRA ticket for a specific worklog by selecting its URL on the "Work Logs" table. 

✔ Reset filters by selecting "Remove All" in the Interaction Manager section at the top right. 

✔ And if you have any questions on additional functionality, please reach out using our [Community Forum](https://community.chartfactor.com/).

# Uninstalling the connector

To uninstall the connector components, follow the steps below:

1. Nagivate to the folder where the [chartfactor-jira-kit](https://github.com/Aktiun/chartfactor-jira-kit.git) repo was cloned as described in previous sections.
2. Uninstall Airbyte following these [instructions](https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart#uninstall-airbyte).
3. Stop and remove the running Postgres container with the command below.

```commandline
docker-compose down
```

If you would like to remove all Postgres persisted data, run the commands below.

```commandline
docker-compose down -v
```

```commandline
rm -rf ./postgres.db
```

4. To remove your Google BigQuery dataset, use the GCP [Delete datasets](https://cloud.google.com/bigquery/docs/managing-datasets#delete-datasets) documentation.

