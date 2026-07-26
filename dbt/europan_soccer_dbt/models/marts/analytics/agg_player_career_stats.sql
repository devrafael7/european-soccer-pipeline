{{ config(
    materialized = 'table',
    tags = ['analytics', 'players']
) }}

with player_match_stats as (

    select *
    from {{ ref('fact_player_match_stats') }}

),

players as (

    select
        player_id,
        player_api_id,
        player_name
    from {{ ref('dim_players') }}

),

aggregated as (

    select
        player_id,
        player_api_id,

        count(distinct match_id) as matches_played,
        count_if(is_starter) as matches_started,
        count_if(not is_starter) as substitute_appearances,

        count(distinct match_season) as seasons_played,
        count(distinct league_id) as leagues_played,
        count(distinct country_id) as countries_played,
        count(distinct team_api_id) as teams_played,

        min(match_date) as first_match_date,
        max(match_date) as last_match_date,

        sum(goals) as total_goals,
        sum(assists) as total_assists,
        sum(goals + assists) as total_goal_contributions,

        sum(shots_on_target) as total_shots_on_target,
        sum(shots_off_target) as total_shots_off_target,
        sum(total_shots) as total_shots,

        sum(fouls_committed) as total_fouls_committed,
        sum(fouls_suffered) as total_fouls_suffered,

        sum(yellow_cards) as total_yellow_cards,
        sum(second_yellow_cards) as total_second_yellow_cards,
        sum(red_cards) as total_red_cards,
        sum(sent_offs) as total_sent_offs,

        sum(crosses) as total_crosses,
        sum(corners_taken) as total_corners_taken,

        count_if(goals > 0) as matches_with_goals,
        count_if(assists > 0) as matches_with_assists

    from player_match_stats

    group by
        player_id,
        player_api_id

)

select
    aggregated.player_id,
    aggregated.player_api_id,
    players.player_name,

    aggregated.matches_played,
    aggregated.matches_started,
    aggregated.substitute_appearances,
    aggregated.seasons_played,
    aggregated.leagues_played,
    aggregated.countries_played,
    aggregated.teams_played,
    aggregated.first_match_date,
    aggregated.last_match_date,

    aggregated.total_goals,
    aggregated.total_assists,
    aggregated.total_goal_contributions,
    aggregated.total_shots_on_target,
    aggregated.total_shots_off_target,
    aggregated.total_shots,
    aggregated.total_fouls_committed,
    aggregated.total_fouls_suffered,
    aggregated.total_yellow_cards,
    aggregated.total_second_yellow_cards,
    aggregated.total_red_cards,
    aggregated.total_sent_offs,
    aggregated.total_crosses,
    aggregated.total_corners_taken,
    aggregated.matches_with_goals,
    aggregated.matches_with_assists,

    round(
        aggregated.total_goals
        / nullif(aggregated.matches_played, 0),
        2
    ) as goals_per_match,

    round(
        aggregated.total_assists
        / nullif(aggregated.matches_played, 0),
        2
    ) as assists_per_match,

    round(
        aggregated.total_goal_contributions
        / nullif(aggregated.matches_played, 0),
        2
    ) as goal_contributions_per_match,

    round(
        100.0 * aggregated.total_shots_on_target
        / nullif(aggregated.total_shots, 0),
        2
    ) as shot_accuracy_pct,

    round(
        100.0 * aggregated.total_goals
        / nullif(aggregated.total_shots, 0),
        2
    ) as goal_conversion_pct

from aggregated

left join players
    on aggregated.player_id = players.player_id
