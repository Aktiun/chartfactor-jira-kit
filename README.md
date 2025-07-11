# ChartFactor JIRA kit

If you would like to visualize the time your team is logging into their JIRA tickets without having to spend hundreds of dollars per month in Tempo licensing fees, then you should read on.

![JIRA Worklogs App](https://github.com/Aktiun/chartfactor-jira-kit/blob/main/JIRA%20App.gif)

This repository allows you to analyze JIRA tickets and worklogs using ChartFactor. Please note that this connector uses either Postgres or the BigQuery emulator as a data warehouse for a lower onboarding barrier.  Consider using these data engines as a destination for small data volumes (e.g. less than 10GB) or for testing purposes. For larger data volumes and for full governance, we recommend using a data warehouse such as Google BigQuery.

# Steps

1. If you are using a Mac, use Homebrew to install Airbyte's abctl.

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

    Please refer to Airbyte's [Quickstart documentation](https://docs.airbyte.com/platform/using-airbyte/getting-started/oss-quickstart) to install abctl if you are using Linux or Windows.

2. Pull this repo using the command below.

    ```commandline
    git clone https://github.com/Aktiun/chartfactor-jira-kit.git
    ```

3. Copy the `.env.example` file to `.env` and fill in the JIRA parameters

4. Execute the command below in your terminal window. Please make sure ports 8000 and 5433 are available in your local computer. 

    ```commandline
    airbyte-jira-pg.sh
    ```

    The command performs the following actions:

    * Deploys Airbyte locally.  Airbyte is an open-source ELT platform that helps teams move data from various sources into data warehouses.
    * Creates Airbyte source, destination, and connection configurations to populate the data warehouse (e.g. Postgres or BigQuery Emulator) with JIRA issues and worklogs.
    * Prepares the "JIRA Worklogs Analysis.cfs" application file that you can later use in ChartFactor Studio. This file contains the visualization configurations.
    * Waits for issue_worklogs and issues tables to appear in the data warehouse

5. Open [ChartFactor Studio](https://chartfactor.com/studio) and use the "Import" function located in the top-right corner of the Studio home page, to import the `JIRA Worklogs Analysis.cfs` file.

You should now be able to open your Studio application.  

✔ Easily narrow down team members and time windows by dragging your mouse on top of the Heat Map, Trend, and Barchart visualizations. 

✔ Open the JIRA ticket for a specific worklog by selecting its URL on the "Work Logs" table. 

✔ Reset filters by selecting "Remove All" in the Interaction Manager section at the top right. 

✔ And if you have any questions on additional functionality, please reach out using our [Community Forum](https://community.chartfactor.com/).
