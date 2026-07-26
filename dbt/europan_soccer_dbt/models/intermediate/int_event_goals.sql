with matches as (

    select
        match_id,
        parse_xml(goal) as goal_xml
    from {{ ref('stg_match') }}
    where goal is not null

),

goal_events as (

    select
        matches.match_id,
        event.value as goal_event
    from matches,
    lateral flatten(
        input => get(matches.goal_xml, '$')
    ) as event

    where get(event.value, '@')::string = 'value'

)

select
    match_id,

    get(
        xmlget(goal_event, 'id'),
        '$'
    )::integer as goal_id,

    get(
        xmlget(goal_event, 'elapsed'),
        '$'
    )::integer as goal_minute,

    get(
        xmlget(goal_event, 'elapsed_plus'),
        '$'
    )::integer as stoppage_time,

    case 
        when get(xmlget(goal_event, 'elapsed'), '$') <= 45 
            then 'First Half'
        else 'Second Half'
    end as match_half,


    try_to_number(
        get(
            xmlget(goal_event, 'player1'),
            '$'
        )::string
    ) as scorer_player_api_id,

    try_to_number(
        get(
            xmlget(goal_event, 'player2'),
            '$'
        )::string
    ) as assist_player_api_id,

    try_to_number(
        get(
            xmlget(goal_event, 'team'),
            '$'
        )::string
    ) as team_api_id,

    get(
        xmlget(goal_event, 'goal_type'),
        '$'
    )::string as goal_type,

    get(
        xmlget(goal_event, 'subtype'),
        '$'
    )::string as shot_type,


    get(
        xmlget(goal_event, 'event_incident_typefk'),
        '$'
    )::integer as incident_type_id,

    'GOAL' as event_attribute

from goal_events

where xmlget(goal_event, 'elapsed') is not null