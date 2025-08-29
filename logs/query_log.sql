-- created_at: 2025-08-29T10:58:23.155256+00:00
-- dialect: bigquery
-- node_id: not available
-- desc: Ensure schema exists
CREATE SCHEMA IF NOT EXISTS `ga4-meta-crm-integration.crm_analytics`;
-- created_at: 2025-08-29T10:58:24.286406700+00:00
-- dialect: bigquery
-- node_id: model.etl_models.staging_meta_ads
-- desc: get_relation adapter call
SELECT table_catalog,
                    table_schema,
                    table_name,
                    table_type
                FROM `ga4-meta-crm-integration`.`crm_analytics`.INFORMATION_SCHEMA.TABLES
                WHERE table_name = 'staging_meta_ads';
-- created_at: 2025-08-29T10:58:26.637581700+00:00
-- dialect: bigquery
-- node_id: model.etl_models.staging_ga4
-- desc: get_relation adapter call
SELECT table_catalog,
                    table_schema,
                    table_name,
                    table_type
                FROM `ga4-meta-crm-integration`.`crm_analytics`.INFORMATION_SCHEMA.TABLES
                WHERE table_name = 'staging_ga4';
-- created_at: 2025-08-29T10:58:28.634243500+00:00
-- dialect: bigquery
-- node_id: model.etl_models.staging_crm_orders
-- desc: get_relation adapter call
SELECT table_catalog,
                    table_schema,
                    table_name,
                    table_type
                FROM `ga4-meta-crm-integration`.`crm_analytics`.INFORMATION_SCHEMA.TABLES
                WHERE table_name = 'staging_crm_orders';
-- created_at: 2025-08-29T10:58:31.177520200+00:00
-- dialect: bigquery
-- node_id: model.etl_models.staging_crm_orders
-- desc: execute adapter call

  
    

    create or replace table `ga4-meta-crm-integration`.`crm_analytics`.`staging_crm_orders`
      
    
    

    OPTIONS()
    as (
      

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
    );
  ;
-- created_at: 2025-08-29T10:58:34.245900900+00:00
-- dialect: bigquery
-- node_id: model.etl_models.crm_orders_transactions
-- desc: get_relation adapter call
SELECT table_catalog,
                    table_schema,
                    table_name,
                    table_type
                FROM `ga4-meta-crm-integration`.`crm_analytics`.INFORMATION_SCHEMA.TABLES
                WHERE table_name = 'crm_orders_transactions';
-- created_at: 2025-08-29T10:58:36.270586600+00:00
-- dialect: bigquery
-- node_id: model.etl_models.crm_orders_transactions
-- desc: execute adapter call

  
    

    create or replace table `ga4-meta-crm-integration`.`crm_analytics`.`crm_orders_transactions`
      
    
    

    OPTIONS()
    as (
      

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
from `ga4-meta-crm-integration`.`crm_analytics`.`staging_crm_orders`
    );
  ;
-- created_at: 2025-08-29T10:58:39.620141+00:00
-- dialect: bigquery
-- node_id: model.etl_models.staging_crm_contacts
-- desc: get_relation adapter call
SELECT table_catalog,
                    table_schema,
                    table_name,
                    table_type
                FROM `ga4-meta-crm-integration`.`crm_analytics`.INFORMATION_SCHEMA.TABLES
                WHERE table_name = 'staging_crm_contacts';
-- created_at: 2025-08-29T10:58:41.829484800+00:00
-- dialect: bigquery
-- node_id: model.etl_models.staging_crm_contacts
-- desc: execute adapter call

  
    

    create or replace table `ga4-meta-crm-integration`.`crm_analytics`.`staging_crm_contacts`
      
    
    

    OPTIONS()
    as (
      

select
    contact_id,
    email,
    created_at,
    country,
    phone,
    email_opt_in
from `ga4-meta-crm-integration`.`crm_analytics`.`staging_crm_contacts`
    );
  ;
-- created_at: 2025-08-29T10:58:44.856965100+00:00
-- dialect: bigquery
-- node_id: model.etl_models.crm_contacts_transactions
-- desc: get_relation adapter call
SELECT table_catalog,
                    table_schema,
                    table_name,
                    table_type
                FROM `ga4-meta-crm-integration`.`crm_analytics`.INFORMATION_SCHEMA.TABLES
                WHERE table_name = 'crm_contacts_transactions';
-- created_at: 2025-08-29T10:58:46.590298+00:00
-- dialect: bigquery
-- node_id: model.etl_models.crm_contacts_transactions
-- desc: execute adapter call

  
    

    create or replace table `ga4-meta-crm-integration`.`crm_analytics`.`crm_contacts_transactions`
      
    
    

    OPTIONS()
    as (
      

select
    contact_id,
    email,
    created_at,
    country,
    phone,
    email_opt_in
from `ga4-meta-crm-integration`.`crm_analytics`.`staging_crm_contacts`
    );
  ;
