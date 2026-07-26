with matches as (

    select *
    from {{ ref('int_match_enriched') }}

),

match_events as (

    select *
    from {{ ref('int_match_events') }}

)

select
    matches.match_id,
    matches.match_date,
    matches.match_season,
    matches.match_stage,

    matches.league_id,
    matches.country_id,

    matches.home_team_api_id,
    matches.away_team_api_id,
    matches.winner_team_api_id,

    matches.home_team_score,
    matches.away_team_score,
    matches.total_goals,
    matches.match_result,

    coalesce(match_events.total_cards, 0) as total_cards,
    coalesce(match_events.total_corners, 0) as total_corners,
    coalesce(match_events.total_crosses, 0) as total_crosses,
    coalesce(match_events.total_fouls, 0) as total_fouls,
    coalesce(match_events.total_shots_off, 0) as total_shots_off,
    coalesce(match_events.total_shots_on, 0) as total_shots_on

from matches

left join match_events
    on matches.match_id = match_events.match_id