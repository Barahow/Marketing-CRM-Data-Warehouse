# Marketing & CRM Data Warehouse: End-to-End ETL and Analytics

Repository implements an end-to-end data warehouse and analytics pipeline. It ingests raw CRM CSVs, Meta Ads API data, and GA4 API data, ingests raw extracts to a Bronze layer on Google Cloud Storage, standardizes and deduplicates in a Silver layer in BigQuery via dbt, and produces analytics-ready Gold tables consumed by Power BI.


1. [Project Summary](#project-summary)
2. [Architecture Overview](#architecture-overview)
3. [Integration Model](#integration-model)
4. [Dataflow](#data-flow)
5. [Data Mart](#data-mart)
6. [Power BI](#power-bi)
7. [Project Overview](#project-overview)
8. [Technical Requirements](#immediate-priorities)
9. [Data Cautions and Limitations](#data-cautions-and-limitations)
---

## Project summary

Purpose: deliver observable, auditable, production-grade dataflows that provide revenue, campaign, and customer analytics.

Inputs: CRM CSVs, Meta Ads API, GA4 API.

Outputs: Gold star-schema tables and Power BI reports: Executive Overview, Acquisition and Ads, Customer Revenue Analysis.

Orchestration: Astronomer Airflow run in Docker. Transformation: dbt with BigQuery adapter. Storage: GCS for Bronze; BigQuery for Silver and Gold.

---

## Architecture overview

![Architecture Overview](docs/screenshots/Data%20Architecture.png)

---

## Integration model

![Integration Model](docs/screenshots/Integration%20Model.png)

---

## Dataflow

![Data Flow](docs/screenshots/DWH_Dataflow.png)

---

## Data mart

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

2. Exquisition and Advertisement

![Exquisition & Advertisement](docs/screenshots/exquisition_ads_tab2.png)

3. Customer Revenue Analysis

![Customer Revenue Analysis](docs/screenshots/customer_revenue_analysis_tab3.png)

---

## Project overview

Bronze

* Immutable raw extracts stored in GCS.

Silver

* dbt staging models that standardize timestamps and currency, deduplicate, and compute atomic metrics such as CTR, CPC, conversions.

Gold

* Business marts and star-schema tables for reporting. Incremental, auditable builds. DBT tests enforce uniqueness, not null, and referential integrity.

Design rules: use UTC timestamps, canonical column names, surrogate keys where required.

---

## Technical requirements

Minimal environment

* GCP project with BigQuery and GCS
* Service account JSON with BigQuery and GCS permissions; set GOOGLE\_APPLICATION\_CREDENTIALS to that key
* Docker Compose or Astronomer CLI to run Airflow locally
* Python 3.8+ for Airflow tasks and extractors
* dbt with BigQuery adapter and configured profiles.yml
* Power BI Desktop for report development

Quick start

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
# start Astronomer Airflow locally (or use docker-compose)
astro dev start
# trigger DAGs in Airflow UI: ingest_crm, ingest_meta_ads, ingest_ga4
cd dbt
dbt deps
dbt run --profiles-dir . --target prod
dbt test --profiles-dir . --target prod
```

Optional tooling: jq for JSON inspection, High-DPI PDF tools for image export.

---

## Data cautions and limitations

* This project used sampled GA4 and Meta Ads data expanded for pipeline testing. Current KPI values are demonstration outputs only.
* Ad-spend, impressions, and conversions may not scale or reflect real-world economics; ROAS and CAC derived from these values can be misleading.
* GA4 sample expansion can break one-to-one attribution; validate transaction\_id linkage in Silver before using campaign-level attribution.
* Before production reporting: replace synthetic sources with production feeds, rescale and validate dim\_meta\_ads.spend, run dbt tests on campaign+date joins, and reconcile audit views for order counts and missing FKs.

---


## Notes

This repository is a demonstration. Validate all source linkages and spend values before using reports for decision-making.


