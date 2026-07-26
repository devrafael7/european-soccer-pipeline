{{ config(
    materialized = 'table',
    tags = ['analytics', 'players', 'teams', 'seasons']
) }}

with player_match_stats as (

    select *
    from {{ ref('fact_player_match_stats') }}

),

players as (

    select
        player_id,
        player_name
    from {{ ref('dim_players') }}

),

teams as (

    select
        team_id,
        team_api_id,
        team_long_name,
        team_short_name
    from {{ ref('dim_teams') }}

),

leagues as (

    select
        league_id,
        league_name
    from {{ ref('dim_leagues') }}

),

countries as (

    select
        country_id,
        country_name
    from {{ ref('dim_countries') }}

),

aggregated as (

    select
        match_season,
        league_id,
        country_id,
        player_id,
        player_api_id,
        team_id,
        team_api_id,

        count(distinct match_id) as matches_played,
        count_if(is_starter) as matches_started,
        count_if(not is_starter) as substitute_appearances,

        sum(goals) as goals,
        sum(assists) as assists,
        sum(goals + assists) as goal_contributions,

        sum(shots_on_target) as shots_on_target,
        sum(shots_off_target) as shots_off_target,
        sum(total_shots) as total_shots,

        sum(fouls_committed) as fouls_committed,
        sum(fouls_suffered) as fouls_suffered,
        sum(yellow_cards) as yellow_cards,
        sum(second_yellow_cards) as second_yellow_cards,
        sum(red_cards) as red_cards,
        sum(sent_offs) as sent_offs,
        sum(crosses) as crosses,
        sum(corners_taken) as corners_taken

    from player_match_stats

    where team_api_id is not null

    group by
        match_season,
        league_id,
        country_id,
        player_id,
        player_api_id,
        team_id,
        team_api_id

)

select
    {{ dbt_utils.generate_surrogate_key([
        'aggregated.match_season',
        'aggregated.team_api_id',
        'aggregated.player_api_id'
    ]) }} as player_team_season_key,

    aggregated.match_season,
    aggregated.league_id,
    leagues.league_name,
    aggregated.country_id,
    countries.country_name,

    aggregated.team_id,
    aggregated.team_api_id,
    teams.team_long_name,
    teams.team_short_name,

    aggregated.player_id,
    aggregated.player_api_id,
    players.player_name,

    aggregated.matches_played,
    aggregated.matches_started,
    aggregated.substitute_appearances,
    aggregated.goals,
    aggregated.assists,
    aggregated.goal_contributions,
    aggregated.shots_on_target,
    aggregated.shots_off_target,
    aggregated.total_shots,
    aggregated.fouls_committed,
    aggregated.fouls_suffered,
    aggregated.yellow_cards,
    aggregated.second_yellow_cards,
    aggregated.red_cards,
    aggregated.sent_offs,
    aggregated.crosses,
    aggregated.corners_taken,

    round(
        aggregated.goal_contributions
        / nullif(aggregated.matches_played, 0),
        2
    ) as goal_contributions_per_match,

    round(
        100.0 * aggregated.shots_on_target
        / nullif(aggregated.total_shots, 0),
        2
    ) as shot_accuracy_pct,

    round(
        100.0 * aggregated.goals
        / nullif(aggregated.total_shots, 0),
        2
    ) as goal_conversion_pct

from aggregated

left join players
    on aggregated.player_id = players.player_id

left join teams
    on aggregated.team_id = teams.team_id

left join leagues
    on aggregated.league_id = leagues.league_id

left join countries
    on aggregated.country_id = countries.country_id
