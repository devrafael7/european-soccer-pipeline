with source as (
    select *
    from {{ source('raw', 'team') }}
),

renamed as (
    select 
        id::integer as team_id,
        team_api_id::integer as team_api_id ,
        team_fifa_api_id::integer team_fifa_api_id,
        nullif(trim(TEAM_LONG_NAME), '') as TEAM_LONG_NAME,
        upper(nullif(trim(TEAM_SHORT_NAME), '')) as TEAM_SHORT_NAME,
        current_timestamp() as loaded_at
    from source
)

select * from
renamed