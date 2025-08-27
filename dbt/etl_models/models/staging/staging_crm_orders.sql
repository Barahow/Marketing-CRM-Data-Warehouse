{{ config(materialized='table') }}

select
    CAST(order_id AS STRING)                as order_id,
    CAST(contact_id AS STRING)              as contact_id,
    CAST(user_pseudo_id AS STRING)         as user_pseudo_id,
    CAST(order_ts AS TIMESTAMP)             as order_ts,
    CAST(order_date AS DATE)                as order_date,
    CAST(amount AS FLOAT64)                 as amount,
    CAST(currency AS STRING)                as currency,
    CAST(items AS INT64)                    as items,
    CAST(campaign_id AS STRING)             as campaign_id,
    CAST(channel AS STRING)                 as channel,
    CAST(utm_source AS STRING)              as utm_source,
    CAST(utm_medium AS STRING)              as utm_medium,
    CAST(transaction_id AS STRING)          as transaction_id,
    CAST(is_repeat AS BOOL)                 as is_repeat,
    CAST(payment_method AS STRING)          as payment_method
from `ga4-meta-crm-integration.crm_analytics.staging_crm_orders`
