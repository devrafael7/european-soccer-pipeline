{{ config(
    materialized = 'table',
    tags = ['analytics', 'leagues', 'seasons']
) }}

with matches as (

    select *
    from {{ ref('fact_matches') }}

),

player_match_stats as (

    select *
    from {{ ref('fact_player_match_stats') }}

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

league_teams as (

    select
        match_season,
        league_id,
        country_id,
        home_team_api_id as team_api_id
    from matches

    union

    select
        match_season,
        league_id,
        country_id,
        away_team_api_id as team_api_id
    from matches

),

team_counts as (

    select
        match_season,
        league_id,
        country_id,
        count(distinct team_api_id) as teams_count

    from league_teams

    group by
        match_season,
        league_id,
        country_id

),

match_metrics as (

    select
        match_season,
        league_id,
        country_id,

        count(*) as matches_played,
        sum(home_team_score) as home_goals,
        sum(away_team_score) as away_goals,
        sum(total_goals) as total_goals,

        count_if(match_result = 'Home Win') as home_wins,
        count_if(match_result = 'Away Win') as away_wins,
        count_if(match_result = 'Draw') as draws,

        min(match_date) as season_first_match_date,
        max(match_date) as season_last_match_date

    from matches

    group by
        match_season,
        league_id,
        country_id

),

player_event_metrics as (

    select
        match_season,
        league_id,
        country_id,

        count(distinct player_api_id) as players_with_recorded_appearances,
        sum(goals) as recorded_player_goals,
        sum(assists) as recorded_assists,
        sum(shots_on_target) as total_shots_on_target,
        sum(shots_off_target) as total_shots_off_target,
        sum(total_shots) as total_shots,
        sum(fouls_committed) as total_fouls_committed,
        sum(fouls_suffered) as total_fouls_suffered,
        sum(yellow_cards) as total_yellow_cards,
        sum(second_yellow_cards) as total_second_yellow_cards,
        sum(red_cards) as total_red_cards,
        sum(crosses) as total_crosses,
        sum(corners_taken) as total_corners_taken

    from player_match_stats

    group by
        match_season,
        league_id,
        country_id

)

select
    {{ dbt_utils.generate_surrogate_key([
        'match_metrics.match_season',
        'match_metrics.league_id'
    ]) }} as league_season_key,

    match_metrics.match_season,
    match_metrics.league_id,
    leagues.league_name,
    match_metrics.country_id,
    countries.country_name,

    team_counts.teams_count,
    match_metrics.matches_played,
    match_metrics.home_goals,
    match_metrics.away_goals,
    match_metrics.total_goals,
    match_metrics.home_wins,
    match_metrics.away_wins,
    match_metrics.draws,
    match_metrics.season_first_match_date,
    match_metrics.season_last_match_date,

    coalesce(player_event_metrics.players_with_recorded_appearances, 0)
        as players_with_recorded_appearances,
    coalesce(player_event_metrics.recorded_player_goals, 0)
        as recorded_player_goals,
    coalesce(player_event_metrics.recorded_assists, 0)
        as recorded_assists,
    coalesce(player_event_metrics.total_shots_on_target, 0)
        as total_shots_on_target,
    coalesce(player_event_metrics.total_shots_off_target, 0)
        as total_shots_off_target,
    coalesce(player_event_metrics.total_shots, 0)
        as total_shots,
    coalesce(player_event_metrics.total_fouls_committed, 0)
        as total_fouls_committed,
    coalesce(player_event_metrics.total_fouls_suffered, 0)
        as total_fouls_suffered,
    coalesce(player_event_metrics.total_yellow_cards, 0)
        as total_yellow_cards,
    coalesce(player_event_metrics.total_second_yellow_cards, 0)
        as total_second_yellow_cards,
    coalesce(player_event_metrics.total_red_cards, 0)
        as total_red_cards,
    coalesce(player_event_metrics.total_crosses, 0)
        as total_crosses,
    coalesce(player_event_metrics.total_corners_taken, 0)
        as total_corners_taken,

    round(
        match_metrics.total_goals
        / nullif(match_metrics.matches_played, 0),
        2
    ) as goals_per_match,

    round(
        100.0 * match_metrics.home_wins
        / nullif(match_metrics.matches_played, 0),
        2
    ) as home_win_pct,

    round(
        100.0 * match_metrics.away_wins
        / nullif(match_metrics.matches_played, 0),
        2
    ) as away_win_pct,

    round(
        100.0 * match_metrics.draws
        / nullif(match_metrics.matches_played, 0),
        2
    ) as draw_pct,

    round(
        coalesce(player_event_metrics.total_shots, 0)
        / nullif(match_metrics.matches_played, 0),
        2
    ) as shots_per_match,

    round(
        coalesce(player_event_metrics.total_fouls_committed, 0)
        / nullif(match_metrics.matches_played, 0),
        2
    ) as fouls_per_match

from match_metrics

left join team_counts
    on match_metrics.match_season = team_counts.match_season
    and match_metrics.league_id = team_counts.league_id
    and match_metrics.country_id = team_counts.country_id

left join player_event_metrics
    on match_metrics.match_season = player_event_metrics.match_season
    and match_metrics.league_id = player_event_metrics.league_id
    and match_metrics.country_id = player_event_metrics.country_id

left join leagues
    on match_metrics.league_id = leagues.league_id

left join countries
    on match_metrics.country_id = countries.country_id
