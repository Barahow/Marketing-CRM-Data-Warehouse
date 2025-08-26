{{ config(materialized='table') }}

select
    PARSE_DATETIME('%Y-%m-%d %H:%M:%S', event_ts) as event_ts,
    user_pseudo_id,
    value_usd,
    transaction_id,
    source,
    medium,
    campaign_name
from `ga4-meta-crm-integration.etl_staging.external_ga4_csv`
