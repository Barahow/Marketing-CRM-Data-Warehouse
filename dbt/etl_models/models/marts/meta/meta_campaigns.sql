{{ config(materialized='table') }}

select
  campaign_id,
  PARSE_DATE('%Y-%m-%d', CAST(date AS STRING))    as date,
  CAST(impressions AS INT64)                       as impressions,
  CAST(clicks AS INT64)                            as clicks,
  CAST(spend AS FLOAT64)                           as spend,
  CAST(conversions AS INT64)                       as conversions,
  CAST(ctr AS FLOAT64)                             as ctr,
  CAST(cpc AS FLOAT64)                             as cpc
from {{ ref('staging_meta_ads') }}
