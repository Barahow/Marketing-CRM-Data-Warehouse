{{ config(materialized='table') }}

select
    CAST(order_id as STRING) as order_id,
    CAST(contact_id as STRING) as contact_id,
    CAST(user_pseudo_id as STRING) as user_pseudo_id,
    CAST(order_ts as TIMESTAMP) as order_ts,
    CAST(order_date as DATE) as order_date,
    CAST(amount as FLOAT64) as amount,
    CAST(currency as STRING) as currency,
    CAST(items as INT64) as items,
    CAST(campaign_id as STRING) as campaign_id,
    CAST(channel as STRING) as channel,
    CAST(utm_source as STRING) as utm_source,
    CAST(utm_medium as STRING) as utm_medium,
    CAST(transaction_id as STRING) as transaction_id,
    CAST(is_repeat as BOOL) as is_repeat,
    CAST(payment_method as STRING) as payment_method
from `ga4-meta-crm-integration.crm_analytics.staging_crm_orders`
