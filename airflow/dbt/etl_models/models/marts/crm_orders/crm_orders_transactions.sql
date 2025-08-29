{{ config(materialized='table') }}

select
    order_id,
    contact_id,
    user_pseudo_id,
    order_ts,
    order_date,
    amount,
    currency,
    items,
    campaign_id,
    channel,
    utm_source,
    utm_medium,
    transaction_id,
    is_repeat,
    payment_method
from {{ ref('staging_crm_orders') }}
