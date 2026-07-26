with source as(
    select *
    from {{ source('raw', 'league') }}
),

renamed as (
    select
        id::integer as league_id,
        country_id::integer as country_id ,
        nullif(trim(name), '') as league_name,
        current_timestamp() as loaded_at
    from source
)

select distinct * 
from renamed
