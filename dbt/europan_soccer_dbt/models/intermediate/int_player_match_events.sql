with matches as (

    select
        match_id,
        home_team_api_id,
        away_team_api_id
    from {{ ref('stg_match') }}

),

goal_events as (

    select
        match_id,
        scorer_player_api_id as player_api_id,
        team_api_id,
        'GOAL' as event_type
    from {{ ref('int_event_goals') }}
    where scorer_player_api_id is not null

    union all

    select
        match_id,
        assist_player_api_id as player_api_id,
        team_api_id,
        'ASSIST' as event_type
    from {{ ref('int_event_goals') }}
    where assist_player_api_id is not null

),

shot_events as (

    select
        match_id,
        kicker_api_id as player_api_id,
        team_api_id,
        'SHOT_ON_TARGET_NON_GOAL' as event_type
    from {{ ref('int_event_shoton') }}
    where kicker_api_id is not null

    union all

    select
        match_id,
        kicker_api_id as player_api_id,
        team_api_id,
        'SHOT_OFF_TARGET' as event_type
    from {{ ref('int_event_shotoff') }}
    where kicker_api_id is not null

),

card_events as (

    select
        match_id,
        card_received_player_api_id as player_api_id,
        team_api_id,

        case
            when card_type = 'Yellow Card'
                then 'YELLOW_CARD'
            when card_type = 'Second Yellow Card'
                then 'SECOND_YELLOW_CARD'
            when card_type = 'Red Card'
                then 'RED_CARD'
            else 'UNKNOWN_CARD'
        end as event_type

    from {{ ref('int_event_card') }}
    where card_received_player_api_id is not null

),

corner_events as (

    select
        match_id,
        corner_kicker_player_api_id as player_api_id,
        team_api_id,
        'CORNER_TAKEN' as event_type
    from {{ ref('int_event_corner') }}
    where corner_kicker_player_api_id is not null

),

cross_events as (

    select
        match_id,
        crosser_player_api_id as player_api_id,
        team_api_id,
        'CROSS' as event_type
    from {{ ref('int_event_cross') }}
    where crosser_player_api_id is not null

),

fouls_committed as (

    select
        match_id,
        foul_committed_player_api_id as player_api_id,
        team_api_id,
        'FOUL_COMMITTED' as event_type
    from {{ ref('int_event_foulcommit') }}
    where foul_committed_player_api_id is not null

),

fouls_suffered as (

    select
        fouls.match_id,
        fouls.fouled_player_api_id as player_api_id,

        case
            when fouls.team_api_id = matches.home_team_api_id
                then matches.away_team_api_id
            when fouls.team_api_id = matches.away_team_api_id
                then matches.home_team_api_id
            else null
        end as team_api_id,

        'FOUL_SUFFERED' as event_type

    from {{ ref('int_event_foulcommit') }} as fouls

    left join matches
        on fouls.match_id = matches.match_id

    where fouls.fouled_player_api_id is not null

),

all_player_events as (

    select * from goal_events
    union all
    select * from shot_events
    union all
    select * from card_events
    union all
    select * from corner_events
    union all
    select * from cross_events
    union all
    select * from fouls_committed
    union all
    select * from fouls_suffered

)

select
    match_id,
    player_api_id,
    max(team_api_id)::integer as event_team_api_id,

    count_if(event_type = 'GOAL') as goals,
    count_if(event_type = 'ASSIST') as assists,

    count_if(event_type = 'SHOT_ON_TARGET_NON_GOAL')
        as shots_on_target_non_goal,

    count_if(
        event_type in ('GOAL', 'SHOT_ON_TARGET_NON_GOAL')
    ) as shots_on_target,

    count_if(event_type = 'SHOT_OFF_TARGET') as shots_off_target,

    count_if(
        event_type in (
            'GOAL',
            'SHOT_ON_TARGET_NON_GOAL',
            'SHOT_OFF_TARGET'
        )
    ) as total_shots,

    count_if(event_type = 'FOUL_COMMITTED') as fouls_committed,
    count_if(event_type = 'FOUL_SUFFERED') as fouls_suffered,

    count_if(event_type = 'YELLOW_CARD') as yellow_cards,
    count_if(event_type = 'SECOND_YELLOW_CARD') as second_yellow_cards,
    count_if(event_type = 'RED_CARD') as red_cards,

    count_if(
        event_type in (
            'YELLOW_CARD',
            'SECOND_YELLOW_CARD',
            'RED_CARD',
            'UNKNOWN_CARD'
        )
    ) as cards_received,

    count_if(
        event_type in ('SECOND_YELLOW_CARD', 'RED_CARD')
    ) as sent_offs,

    count_if(event_type = 'CROSS') as crosses,
    count_if(event_type = 'CORNER_TAKEN') as corners_taken

from all_player_events

group by
    match_id,
    player_api_id