{{ config(
    materialized = 'table',
    tags = ['analytics', 'players', 'leaderboard']
) }}

with player_stats as (

    select *
    from {{ ref('agg_player_league_season_stats') }}

)

select
    player_league_season_key,
    match_season,
    league_id,
    league_name,
    country_id,
    country_name,
    player_id,
    player_api_id,
    player_name,
    matches_played,
    matches_started,
    substitute_appearances,
    teams_played,
    goals,
    assists,
    goal_contributions,
    shots_on_target,
    shots_off_target,
    total_shots,
    fouls_committed,
    fouls_suffered,
    yellow_cards,
    second_yellow_cards,
    red_cards,
    sent_offs,
    crosses,
    corners_taken,
    goals_per_match,
    assists_per_match,
    goal_contributions_per_match,
    shot_accuracy_pct,
    goal_conversion_pct,

    dense_rank() over (
        partition by match_season, league_id
        order by goals desc
    ) as goals_rank,

    dense_rank() over (
        partition by match_season, league_id
        order by assists desc
    ) as assists_rank,

    dense_rank() over (
        partition by match_season, league_id
        order by goal_contributions desc
    ) as goal_contributions_rank,

    dense_rank() over (
        partition by match_season, league_id
        order by total_shots desc
    ) as total_shots_rank,

    dense_rank() over (
        partition by match_season, league_id
        order by shot_accuracy_pct desc nulls last
    ) as shot_accuracy_rank,

    dense_rank() over (
        partition by match_season, league_id
        order by goal_conversion_pct desc nulls last
    ) as goal_conversion_rank

from player_stats
