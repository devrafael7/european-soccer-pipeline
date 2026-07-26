with player_atb as(
    select * exclude (last_atb_update_date, player_fifa_api_id)
    from {{ ref('stg_player_attributes') }}
)

select * from player_atb