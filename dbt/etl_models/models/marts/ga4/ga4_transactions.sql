{{ config(materialized='table') }}

select
    user_pseudo_id,
    transaction_id,
    source,
    medium,
    campaign_name,
    CAST(event_ts as DATETIME) as event_ts,
    CAST(value_usd as FLOAT64) as value_usd
from {{ ref('staging_ga4') }}
