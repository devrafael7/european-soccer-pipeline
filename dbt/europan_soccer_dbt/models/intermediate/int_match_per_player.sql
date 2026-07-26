with matches as (

    select
        match_id,
        home_team_api_id,
        away_team_api_id,
        home_player_1,
        home_player_2,
        home_player_3,
        home_player_4,
        home_player_5,
        home_player_6,
        home_player_7,
        home_player_8,
        home_player_9,
        home_player_10,
        home_player_11,
        away_player_1,
        away_player_2,
        away_player_3,
        away_player_4,
        away_player_5,
        away_player_6,
        away_player_7,
        away_player_8,
        away_player_9,
        away_player_10,
        away_player_11
    from {{ ref('stg_match') }}

),

unpivoted_players as (

    select
        match_id,
        home_team_api_id,
        away_team_api_id,
        player_slot,
        player_api_id
    from matches
    unpivot (
        player_api_id for player_slot in (
            home_player_1,
            home_player_2,
            home_player_3,
            home_player_4,
            home_player_5,
            home_player_6,
            home_player_7,
            home_player_8,
            home_player_9,
            home_player_10,
            home_player_11,
            away_player_1,
            away_player_2,
            away_player_3,
            away_player_4,
            away_player_5,
            away_player_6,
            away_player_7,
            away_player_8,
            away_player_9,
            away_player_10,
            away_player_11
        )
    )

),

lineup as (

    select
        match_id,
        player_api_id::integer as player_api_id,

        case
            when player_slot ilike 'HOME_PLAYER_%'
                then home_team_api_id
            when player_slot ilike 'AWAY_PLAYER_%'
                then away_team_api_id
        end as team_api_id,

        case
            when player_slot ilike 'HOME_PLAYER_%'
                then 'Home'
            when player_slot ilike 'AWAY_PLAYER_%'
                then 'Away'
        end as team_side,

        try_to_number(regexp_substr(player_slot, '[0-9]+$')) as lineup_slot,
        lower(player_slot) as player_slot,
        true as is_starter

    from unpivoted_players
    where player_api_id is not null

    qualify row_number() over (
        partition by match_id, player_api_id
        order by player_slot
    ) = 1

),

players as (

    select
        player_id,
        player_api_id,
        player_name
    from {{ ref('stg_player') }}

)

select
    lineup.match_id,
    players.player_id,
    lineup.player_api_id,
    lineup.team_api_id,
    lineup.team_side,
    lineup.lineup_slot,
    lineup.player_slot,
    lineup.is_starter,
    players.player_name

from lineup

left join players
    on lineup.player_api_id = players.player_api_id