select
    campaign_id,
    impressions,
    clicks,
    spend,
    conversions,
    ctr,
    cpc,
    parse_date('%Y-%m-%d', `date`) as `date`
from `ga4-meta-crm-integration.etl_staging.external_meta_ads_csv`
