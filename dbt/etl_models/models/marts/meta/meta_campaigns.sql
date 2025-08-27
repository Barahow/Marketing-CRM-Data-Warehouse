{{ config(materialized='table') }}

select
    campaign_id,
    PARSE_DATE('%Y-%m-%d', CAST(date as STRING)) as date,
    CAST(impressions as INT64) as impressions,
    CAST(clicks as INT64) as clicks,
    CAST(spend as FLOAT64) as spend,
    CAST(conversions as INT64) as conversions,
    CAST(ctr as FLOAT64) as ctr,
    CAST(cpc as FLOAT64) as cpc
from {{ ref('staging_meta_ads') }}
