with source as (
    select * 
    from {{ source('raw', 'player') }}
),

renamed as (
    select
        ID::integer as player_id,
        player_api_id::integer as player_api_id,
        nullif(trim(PLAYER_NAME), '') as player_name,
        player_fifa_api_id::integer as player_fifa_api_id,
        birthday::date as player_birthday,
        case when
            height <= 0 then null
            else height
        end as height,
        case when 
            weight <= 30 then null
            else weight
        end as weight,
        current_timestamp() as loaded_at
    from source
)


select * from
renamed