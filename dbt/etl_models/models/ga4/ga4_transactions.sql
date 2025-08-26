{{ config(materialized='view') }}

with raw_ga4 as (
    select
        PARSE_DATETIME('%Y-%m-%dT%H:%M:%S', event_ts) as event_ts,
        user_pseudo_id,
        value_usd,
        transaction_id,
        source,
        medium,
        campaign_name
    from {{ source('ga4_raw', 'external_ga4_csv') }}
)

select
    event_ts,
    user_pseudo_id,
    value_usd,
    transaction_id,
    source,
    medium,
    campaign_name
from raw_ga4
