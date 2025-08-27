{{ config(materialized='table') }}

select
    contact_id,
    email,
    created_at,
    country,
    phone,
    email_opt_in
from `ga4-meta-crm-integration.crm_analytics.staging_contacts`
