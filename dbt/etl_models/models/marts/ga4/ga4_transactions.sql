{{ config(materialized='table') }}

select
  CAST(event_ts AS DATETIME) as event_ts,
  user_pseudo_id,
  CAST(value_usd AS FLOAT64) as value_usd,
  transaction_id,
  source,
  medium,
  campaign_name
from {{ ref('staging_ga4') }}
