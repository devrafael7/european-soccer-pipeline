with matches as (
    select 
        match_id
    from {{ ref('stg_match') }}
),

e_card as (
    select 
        match_id,
        count(card_id) over (partition by match_id) as total_cards
    from {{ ref('int_event_card') }}
),

e_corner as (
    select 
        match_id,
        count(corner_id) over (partition by match_id) as total_corners
    from {{ ref('int_event_corner') }}
),

e_cross as (
    select 
        match_id,
        count(cross_id) over (partition by match_id) as total_crosses
    from {{ ref('int_event_cross') }}
),

e_foul as (
    select 
        match_id,
        count(foul_id) over (partition by match_id) as total_fouls
    from {{ ref('int_event_foulcommit') }}
),

e_goal as (
    select 
        match_id,
        count(goal_id) over (partition by match_id) as total_goals
    from {{ ref('int_event_goals') }}
),

e_shotoff as (
    select 
        match_id,
        count(shotoff_id) over (partition by match_id) as total_shots_off
    from {{ ref('int_event_shotoff') }}
),

e_shoton as (
    select 
        match_id,
        count(shoton_id) over (partition by match_id) as total_shots_on
    from {{ ref('int_event_shoton') }}
)

select 
    distinct (matches.match_id),
    e_card.total_cards,
    e_corner.total_corners,
    e_cross.total_crosses,
    e_foul.total_fouls,
    e_goal.total_goals,
    e_shotoff.total_shots_off,
    e_shoton.total_shots_on
from matches

left join e_card
    on matches.match_id = e_card.match_id

left join e_corner
    on matches.match_id = e_corner.match_id
    
left join e_cross
    on matches.match_id = e_cross.match_id

left join e_foul
    on matches.match_id = e_foul.match_id
    
left join e_goal
    on matches.match_id = e_goal.match_id

left join e_shotoff
    on matches.match_id = e_shotoff.match_id

left join e_shoton
    on matches.match_id = e_shoton.match_id
