with roster_players as (

    select *
    from {{ ref('int_match_per_player') }}

),

player_events as (

    select *
    from {{ ref('int_player_match_events') }}

),

matches as (

    select
        match_id,
        match_date,
        match_season,
        match_stage,
        league_id,
        country_id,
        home_team_api_id,
        away_team_api_id
    from {{ ref('int_match_enriched') }}

),

players as (

    select
        player_id,
        player_api_id
    from {{ ref('dim_players') }}

),

teams as (

    select
        team_id,
        team_api_id
    from {{ ref('dim_teams') }}

),

player_keys as (

    select
        match_id,
        player_api_id
    from roster_players

    union

    select
        match_id,
        player_api_id
    from player_events

),

joined as (

    select
        player_keys.match_id,
        player_keys.player_api_id,

        coalesce(
            roster_players.team_api_id,
            player_events.event_team_api_id
        )::integer as team_api_id,

        roster_players.team_side as roster_team_side,
        roster_players.lineup_slot,
        coalesce(roster_players.is_starter, false) as is_starter,

        player_events.goals,
        player_events.assists,
        player_events.shots_on_target_non_goal,
        player_events.shots_on_target,
        player_events.shots_off_target,
        player_events.total_shots,
        player_events.fouls_committed,
        player_events.fouls_suffered,
        player_events.yellow_cards,
        player_events.second_yellow_cards,
        player_events.red_cards,
        player_events.cards_received,
        player_events.sent_offs,
        player_events.crosses,
        player_events.corners_taken

    from player_keys

    left join roster_players
        on player_keys.match_id = roster_players.match_id
        and player_keys.player_api_id = roster_players.player_api_id

    left join player_events
        on player_keys.match_id = player_events.match_id
        and player_keys.player_api_id = player_events.player_api_id

)

select
    {{ dbt_utils.generate_surrogate_key([
        'joined.match_id',
        'joined.player_api_id'
    ]) }} as match_player_key,

    joined.match_id,
    players.player_id,
    joined.player_api_id,
    teams.team_id,
    joined.team_api_id,

    matches.match_date,
    matches.match_season,
    matches.match_stage,
    matches.league_id,
    matches.country_id,

    coalesce(
        joined.roster_team_side,
        case
            when joined.team_api_id = matches.home_team_api_id
                then 'Home'
            when joined.team_api_id = matches.away_team_api_id
                then 'Away'
        end
    ) as team_side,

    joined.lineup_slot,
    joined.is_starter,

    coalesce(joined.goals, 0) as goals,
    coalesce(joined.assists, 0) as assists,
    coalesce(joined.shots_on_target_non_goal, 0)
        as shots_on_target_non_goal,
    coalesce(joined.shots_on_target, 0) as shots_on_target,
    coalesce(joined.shots_off_target, 0) as shots_off_target,
    coalesce(joined.total_shots, 0) as total_shots,
    coalesce(joined.fouls_committed, 0) as fouls_committed,
    coalesce(joined.fouls_suffered, 0) as fouls_suffered,
    coalesce(joined.yellow_cards, 0) as yellow_cards,
    coalesce(joined.second_yellow_cards, 0) as second_yellow_cards,
    coalesce(joined.red_cards, 0) as red_cards,
    coalesce(joined.cards_received, 0) as cards_received,
    coalesce(joined.sent_offs, 0) as sent_offs,
    coalesce(joined.crosses, 0) as crosses,
    coalesce(joined.corners_taken, 0) as corners_taken

from joined

left join matches
    on joined.match_id = matches.match_id

left join players
    on joined.player_api_id = players.player_api_id

left join teams
    on joined.team_api_id = teams.team_api_id