{{ config(
    materialized = 'table',
    tags = ['analytics', 'teams', 'standings']
) }}

with matches as (

    select *
    from {{ ref('fact_matches') }}

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

team_matches as (

    select
        match_id,
        match_date,
        match_season,
        match_stage,
        league_id,
        country_id,
        home_team_api_id as team_api_id,
        away_team_api_id as opponent_team_api_id,
        'Home' as venue,
        home_team_score as goals_for,
        away_team_score as goals_against,

        case
            when home_team_score > away_team_score then 'Win'
            when home_team_score = away_team_score then 'Draw'
            else 'Loss'
        end as result

    from matches

    union all

    select
        match_id,
        match_date,
        match_season,
        match_stage,
        league_id,
        country_id,
        away_team_api_id as team_api_id,
        home_team_api_id as opponent_team_api_id,
        'Away' as venue,
        away_team_score as goals_for,
        home_team_score as goals_against,

        case
            when away_team_score > home_team_score then 'Win'
            when away_team_score = home_team_score then 'Draw'
            else 'Loss'
        end as result

    from matches

),

aggregated as (

    select
        match_season,
        league_id,
        country_id,
        team_api_id,

        count(*) as matches_played,
        count_if(result = 'Win') as wins,
        count_if(result = 'Draw') as draws,
        count_if(result = 'Loss') as losses,

        count_if(venue = 'Home') as home_matches,
        count_if(venue = 'Away') as away_matches,
        count_if(venue = 'Home' and result = 'Win') as home_wins,
        count_if(venue = 'Away' and result = 'Win') as away_wins,

        sum(goals_for) as goals_for,
        sum(goals_against) as goals_against,
        sum(goals_for) - sum(goals_against) as goal_difference,

        sum(
            case
                when result = 'Win' then 3
                when result = 'Draw' then 1
                else 0
            end
        ) as points,

        count_if(goals_against = 0) as clean_sheets,
        count_if(goals_for = 0) as matches_without_scoring,
        max(goals_for) as most_goals_in_match,
        max(goals_for - goals_against) as biggest_win_margin,
        min(match_date) as first_match_date,
        max(match_date) as last_match_date

    from team_matches

    group by
        match_season,
        league_id,
        country_id,
        team_api_id

),

enriched as (

    select
        aggregated.*,
        teams.team_id,
        teams.team_long_name,
        teams.team_short_name,
        leagues.league_name,
        countries.country_name,

        round(
            100.0 * aggregated.wins
            / nullif(aggregated.matches_played, 0),
            2
        ) as win_rate_pct,

        round(
            aggregated.goals_for
            / nullif(aggregated.matches_played, 0),
            2
        ) as goals_for_per_match,

        round(
            aggregated.goals_against
            / nullif(aggregated.matches_played, 0),
            2
        ) as goals_against_per_match,

        round(
            aggregated.points
            / nullif(aggregated.matches_played, 0),
            2
        ) as points_per_match

    from aggregated

    left join teams
        on aggregated.team_api_id = teams.team_api_id

    left join leagues
        on aggregated.league_id = leagues.league_id

    left join countries
        on aggregated.country_id = countries.country_id

)

select
    {{ dbt_utils.generate_surrogate_key([
        'match_season',
        'league_id',
        'team_api_id'
    ]) }} as team_season_key,

    dense_rank() over (
        partition by match_season, league_id
        order by
            points desc,
            goal_difference desc,
            goals_for desc,
            team_api_id
    ) as calculated_league_position,

    match_season,
    league_id,
    league_name,
    country_id,
    country_name,
    team_id,
    team_api_id,
    team_long_name,
    team_short_name,
    matches_played,
    wins,
    draws,
    losses,
    home_matches,
    away_matches,
    home_wins,
    away_wins,
    goals_for,
    goals_against,
    goal_difference,
    points,
    clean_sheets,
    matches_without_scoring,
    most_goals_in_match,
    biggest_win_margin,
    first_match_date,
    last_match_date,
    win_rate_pct,
    goals_for_per_match,
    goals_against_per_match,
    points_per_match

from enriched
