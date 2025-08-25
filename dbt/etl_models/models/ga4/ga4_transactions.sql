-- models/ga4/ga4_transactions.sql
{{ config(
    materialized='view'
) }}

with raw_ga4 as (

    select
        parse_datetime(event_ts, 'yyyy-MM-dd HH:mm:ss') as event_ts,
        user_pseudo_id,
        value_usd,
        transaction_id,
        source,
        medium,
        campaign_name
    from {{ source('ga4_raw', 'events') }}ss

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

