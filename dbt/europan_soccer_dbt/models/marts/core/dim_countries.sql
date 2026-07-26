with countries as (
    select * exclude (loaded_at)
    from {{ ref('stg_country') }}
)

select * from countries