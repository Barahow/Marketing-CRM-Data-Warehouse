# Marketing & CRM Data Warehouse: End-to-End ETL and Analytics

Repository implements an end-to-end data warehouse and analytics pipeline. It ingests raw CRM CSVs, Meta Ads API data, and GA4 API data, lands raw extracts to a Bronze layer on Google Cloud Storage, standardizes and deduplicates in a Silver layer in BigQuery via dbt, and produces analytics-ready Gold tables consumed by Power BI.

---

## Table of Contents

1. [Project Summary](#project-summary)
2. [Architecture Overview](#architecture-overview)
3. [Integration Model](#integration-model)
4. [Dataflow](#dataflow)
5. [Data Mart](#data-mart)
6. [Power BI](#power-bi)
7. [Project Overview](#project-overview)
8. [Technical Requirements](#technical-requirements)
9. [Observability and Airflow tracking](#observability-and-airflow-tracking)
10. [Data Cautions and Limitations](#data-cautions-and-limitations)
11. [Notes](#notes)

---

## Project Summary

Purpose: deliver observable, auditable, production-grade dataflows that provide revenue, campaign, and customer analytics.

Inputs: CRM CSVs, Meta Ads API, GA4 API.

Outputs: Gold star-schema tables and Power BI reports: Executive Overview, Acquisition and Ads, Customer Revenue Analysis.

CI/CD: GitHub Actions runs dbt build and tests on push/PR, SQLFluff linting enforces SQL style, and critical tests are tagged to gate failures.

Orchestration: Astronomer Airflow run in Docker. Transformation: dbt with BigQuery adapter. Storage: GCS for Bronze; BigQuery for Silver and Gold.

---

## Architecture Overview

![Architecture Overview](docs/screenshots/Data%20Architecture.png)

Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV files into GCS using Airflow DAG.
Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
Gold Layer: Houses business-ready data modeled into a star schema required for reporting and analytics.

---

## Integration Model

![Integration Model](docs/screenshots/Integration%20Model.png)

---

## Dataflow

![Dataflow](docs/screenshots/DWH_Dataflow.png)

---

## Data Mart

Core objects

* fact\_orders
* dim\_contacts
* dim\_campaign
* dim\_meta\_ads
* dim\_ga4\_events

![Data Mart](docs/screenshots/data_marts.png)

---

## Power BI

Report tabs

* Executive Overview
* Acquisition and Ads
* Customer Revenue Analysis

1. Executive Overview

![Executive Overview](docs/screenshots/executive_overview_tab1.png)

2. Acquisition and Ads

![Acquisition & Advertisement](docs/screenshots/exquisition_ads_tab2.png)

3. Customer Revenue Analysis

![Customer Revenue Analysis](docs/screenshots/customer_revenue_analysis_tab3.png)

---

## Project Overview

Bronze

* Immutable raw extracts stored in GCS.

Silver

* dbt staging models that standardize timestamps and currency, deduplicate, and compute atomic metrics such as CTR, CPC, conversions.

Gold

* Business marts and star-schema tables for reporting. Incremental, auditable builds. DBT tests enforce uniqueness, not null, and referential integrity.

Design rules: use UTC timestamps, canonical column names, surrogate keys where required.

---

## Technical Requirements

Minimal environment

* GCP project with BigQuery and GCS
* Service account JSON with BigQuery and GCS permissions; set `GOOGLE_APPLICATION_CREDENTIALS` to that key
* Docker Compose or Astronomer CLI to run Airflow locally
* Python 3.8+ for Airflow tasks and extractors
* dbt with BigQuery adapter and configured `profiles.yml`
* Power BI Desktop for report development

Quick start

```bash
export GOOGLE_APPLICATIONS_CREDENTIALS="yourpath"
# start Astronomer Airflow locally (or use docker-compose)
astro dev start
# trigger DAGs in Airflow UI: ingest_crm, ingest_meta_ads, ingest_ga4
cd dbt
dbt deps
dbt run --profiles-dir . --target prod
dbt test --profiles-dir . --target prod
```

---

## Observability and Airflow tracking

Airflow is the primary source of runtime observability for this project. The repository includes a monitoring DAG that summarises status across key ETL DAGs and sends alerts. Documented expectations and tracked metrics below.

What Airflow tracks (builtin)

* DAG run metadata: logical date, start and end timestamps, run duration, run state (success, failed, running).
* Task metadata: start and end timestamps, duration, state, retries.
* Task logs: per-task stdout/stderr and full stacktrace attached to task attempts.
* SLA misses: if configured, Airflow records SLA misses for tasks with `sla=timedelta(...)`.
* XComs: for passing summaries or detailed diagnostics between tasks or to alert tasks.

Repository-level monitoring behaviour

* A `monitoring_dag` is provided. It checks the latest runs for key DAGs (`ga5_meta_ads_loader`, `dbt_staging_run_dag`, `dbt_marts_run_dag`) and pushes a brief XCom summary.
* An EmailOperator consumes the XCom and sends a single email summary to the address stored in Airflow Variable `alert_email`.
* Task-level logs and stacktraces are available from the Airflow UI and included as links in the UI for faster triage.

Recommended tracked metrics and thresholds (document these; adjust to team needs)

| Metric            | Threshold               | Alert channel     | Notes                                                          |
| ----------------- | ----------------------- | ----------------- | -------------------------------------------------------------- |
| DAG run state     | failed                  | Email             | monitor latest DAG run state; include failed task name         |
| DAG run duration  | > expected runtime \* 2 | Email / Slack     | Flag long running runs indicating resource or query issues     |
| Failed task count | > 0                     | Email             | Include task\_id, try\_number, log link                        |
| SLA miss          | any                     | Email + dashboard | Critical dbt marts and ingestion tasks should have SLA defined |

How to reproduce alerts and troubleshoot

1. Inspect monitoring DAG run in Airflow UI to see XCom summary.
2. Click through to failing DAG run; open failed task and view logs and stacktrace.
3. Re-run failed task or DAG from UI after fixing root cause.

Notes on production hardening (describe, do not require for this repo)

* Add task-level alerting with more granular messages and automatic inclusion of log links.
* Integrate Airflow metrics with Prometheus and Grafana or export logs to a central logging system for dashboards and long-term retention.
* Add escalation: Slack or PagerDuty for critical failures, with retry and deduplication logic.
* Define SLAs for key DAGs and configure Airflow to notify on SLA misses.

---

## Data Cautions and Limitations

Data cautions and limitations

The data used here are expanded GA4 and Meta Ads samples created for pipeline validation. KPI values are illustrative and not for production decisions.

Synthetic ad-spend, impressions, and conversions do not reflect real-world economics. Treat ROAS and CAC as illustrative.

Sample expansion can disrupt source-level attribution. Validate transaction\_id linkage between Silver and source tables before using campaign-level attribution.

Pre-production requirements: replace synthetic feeds with production data; rescale and validate dim\_meta\_ads.spend; add dbt tests on campaign+date joins and transaction counts; reconcile audit views to verify order counts and referential integrity.

---

## Notes

Include links to dbt docs site, CI badges, and monitoring dashboards if available in production deployments.




