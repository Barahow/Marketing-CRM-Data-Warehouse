# end-to-end-etl-marketing-crm


Data Warehouse and Analytics Project

This repository is a complete showcase of an end-to-end modern data warehouse and analytics pipeline. The project ingests raw data from CSV files, Meta Ads API, and GA4 API, processes and models it through a medallion (Bronze, Silver, Gold) architecture in Google BigQuery, and visualizes it in Power BI.

The solution is orchestrated with Astronomer Airflow running in Docker, uses Google Cloud Storage (GCS) as the landing zone, BigQuery as the data warehouse, dbt for transformations, and Power BI for business dashboards.



## Table of Contents

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

## Project Summary
End-to-end data warehouse and analytics implementation. Ingests CRM CSVs, Meta Ads API, and GA4 API. Raw extracts land in a Bronze layer on Google Cloud Storage, are cleaned and normalized in a Silver layer in BigQuery via dbt, and are modeled into analytics-ready Gold tables consumed by Power BI. Orchestration is managed by Astronomer Airflow running in Docker. Power BI contains three report tabs: Executive Overview, Acquisition & Ads, Customer Revenue Analysis. 

---

## Architecture Overview


![Architecture Overview](docs/screenshots/Data%20Architecture.png)



---

## Integration Model 



![Integration Model ](docs/screenshots/Integration%20Model.png)




---

## Dataflow

![Data Flow ](docs/screenshots/DWH_Dataflow.png)

---

## Data Mart
![Data Flow ](docs/screenshots/data_marts.png)

---

## Power BI 

Tabs

1. Revenue and Product Performance - primary business translation
2. Customer Insights and Segmentation
3. Support and Customer Satisfaction

1. Executive Overview

![Executive Overview](docs/screenshots/executive_overview_tab1.png)

2. Exquisition and Advertisement

![Exquisition & Advertisement](docs/screenshots/exquisition_ads_tab2.png)

3. Customer Revenue Analysis

![Customer Revenue Analysis](docs/screenshots/customer_revenue_analysis_tab3.png)


---

## Project Overview
Purpose: provide reliable, observable, production-grade dataflows that deliver revenue, customer, and campaign analytics.

Core outputs and flows

* Bronze: raw CSV/API dumps retained in GCS.

* Silver: dbt staging models that standardize dates/currency, deduplicate, and compute atomic metrics (CTR, CPC, conversions).

* Gold: business marts and star-schema tables for reporting:

- fact_orders

- dim_contacts

- dim_campaign

- dim_meta_ads

- dim_ga4_events

- Power BI reports built on Gold tables with tabs:

* Orchestration and execution: DAGs run ingestion, Bronze→Silver loads, and dbt runs to populate Gold.

Design rules enforced

UTC timestamps, canonical column names, surrogate keys where needed.

dbt tests for uniqueness, not-null, and referential integrity.

Bronze is immutable; Silver and Gold are built incrementally and auditable

---

## Technical Requirements

GCP project with BigQuery and GCS access.

Service account JSON key with BigQuery and GCS permissions. Set GOOGLE_APPLICATION_CREDENTIALS to that key.

Astronomer (Astro CLI) or Docker Compose to run Airflow locally. Astronomer recommended.

Python 3.8+ for Airflow tasks and API extractors.

dbt with the BigQuery adapter and configured profiles.yml.

Power BI Desktop for report development and export.

Optional: CLI tools for JSON inspection (jq), PDF tooling for high-DPI export of images.


```
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
astro dev start        # start Astronomer Airflow locally
# trigger DAGs in Airflow UI: ingest_crm, ingest_meta_ads, ingest_ga4
cd dbt
dbt deps
dbt run --profiles-dir . --target prod
dbt test --profiles-dir . --target prod
```

---

## Data Cautions and Limitations

* Used sampled GA4 and Meta Ads inputs that were expanded for pipeline and visualization testing. Consequences and required controls:

* Ad-spend, impressions, and conversions may not scale or align with real-world economics; ROAS and CAC derived from these values can be misleading.

* High AOV, extreme ROAS, or anomalous CAC values likely reflect synthetic expansion and/or unscaled spend rather than true performance.

* GA4 sample expansion can break one-to-one attribution assumptions; always validate transaction_id linkage in Silver before using campaign-level attribution.

* Required action before production reporting: rescale and validate dim_meta_ads.spend in Silver, run dbt tests on campaign+date joins, and reconcile audit views (order counts, missing FKs).
* Treat current KPI values as demonstration outputs only until source spend, impressions, and transaction linkages are validated and replaced with production feeds.
---


