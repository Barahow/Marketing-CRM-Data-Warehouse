{{ config(materialized='table') }}

select
    contact_id,
    email,
    created_at,
    country,
    phone,
    email_opt_in
from {{ ref('staging_crm_contacts') }}
