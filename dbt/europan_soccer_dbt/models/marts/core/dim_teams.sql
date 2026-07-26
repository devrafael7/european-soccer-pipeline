with team as(
    select * exclude (team_fifa_api_id, loaded_at)
    from {{ ref('stg_team') }}
)

select * from team