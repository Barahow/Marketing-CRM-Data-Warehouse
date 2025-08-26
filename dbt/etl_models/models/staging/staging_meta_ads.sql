{{ config(materialized='table') }}

select
    campaign_id,
    parse_date('%Y-%m-%d', date) as date,
    impressions,
    clicks,
    spend,
    conversions,
    ctr,
    cpc
from `ga4-meta-crm-integration.etl_staging.external_meta_ads_csv`
