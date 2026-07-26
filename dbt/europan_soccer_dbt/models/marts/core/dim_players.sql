with player as(
    select * exclude (loaded_at, player_fifa_api_id)
    from {{ ref('stg_player') }}
) 

select * from player