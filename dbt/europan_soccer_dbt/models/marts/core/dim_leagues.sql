with league as (
    select *
    from {{ ref('stg_league') }}
),

country as (
    select * 
    from {{ ref('stg_country') }}
)

select 
    league.league_id,
    league.league_name,
    league.country_id,
    country.country_name
from league
left join country 
    on league.country_id = country.country_id