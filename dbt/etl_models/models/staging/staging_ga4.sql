select
    user_pseudo_id,
    transaction_id,
    source,
    medium,
    campaign_name,
    PARSE_DATETIME('%Y-%m-%d %H:%M:%S', event_ts) as event_ts,
    CAST(value_usd as FLOAT64) as value_usd
from `ga4-meta-crm-integration.etl_staging.external_ga4_csv`
