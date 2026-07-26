with source as (
    select * 
    from {{ source('raw', 'country') }}
),

renamed as (
    select 
        id::integer as country_id,
        nullif(trim(name), '') as country_name,
        current_timestamp() as loaded_at

    from source
) 

select distinct *
from renamed