{{ config(materialized='table') }}

select
    contact_id,
    email,
    created_at,
    country,
    phone,
    email_opt_in
from {{ source('crm_raw', 'staging_crm_contacts') }}
