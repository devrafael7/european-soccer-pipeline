with countries as (

    select *
    from {{ ref('stg_country') }}

),

leagues as (

    select *
    from {{ ref('stg_league') }}

),

teams as (

    select *
    from {{ ref('stg_team') }}

),

matches as (

    select *
    from {{ ref('stg_match') }}

)

select
    matches.match_id,
    matches.match_date,
    matches.match_season,
    matches.match_stage,

    matches.country_id,
    countries.country_name,

    matches.league_id,
    leagues.league_name,

    matches.home_team_api_id,
    home_team.team_long_name as home_team_long_name,
    home_team.team_short_name as home_team_short_name,

    matches.away_team_api_id,
    away_team.team_long_name as away_team_long_name,
    away_team.team_short_name as away_team_short_name,

    matches.home_team_goal as home_team_score,
    matches.away_team_goal as away_team_score,

    matches.home_team_goal + matches.away_team_goal as total_goals,

    case
        when matches.home_team_goal > matches.away_team_goal
            then matches.home_team_api_id
        when matches.home_team_goal < matches.away_team_goal
            then matches.away_team_api_id
        else null
    end as winner_team_api_id,

    case
        when matches.home_team_goal > matches.away_team_goal
            then home_team.team_long_name
        when matches.home_team_goal < matches.away_team_goal
            then away_team.team_long_name
        else null
    end as match_winner,

    case
        when matches.home_team_goal > matches.away_team_goal
            then 'Home Win'
        when matches.home_team_goal < matches.away_team_goal
            then 'Away Win'
        else 'Draw'
    end as match_result

from matches

left join teams as home_team
    on matches.home_team_api_id = home_team.team_api_id

left join teams as away_team
    on matches.away_team_api_id = away_team.team_api_id

left join leagues
    on matches.league_id = leagues.league_id

left join countries
    on matches.country_id = countries.country_id