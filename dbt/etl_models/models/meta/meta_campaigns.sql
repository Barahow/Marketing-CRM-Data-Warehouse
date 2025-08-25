with raw_meta as (

    select
        campaign_id,
        date,
        impressions,
        clicks,
        spend,
        conversions,
        ctr,
        cpc
    from {{ source('meta_raw', 'campaigns') }}

)

select * from raw_meta

