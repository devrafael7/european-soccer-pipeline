with team_attributes as(
    select * exclude (team_fifa_api_id, loaded_at)
    from {{ ref('stg_team_attributes') }}
)

select * from team_attributes