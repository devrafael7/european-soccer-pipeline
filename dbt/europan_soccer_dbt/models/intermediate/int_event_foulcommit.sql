with matches as(
    select 
        match_id,
        parse_xml(foulcommit) as foul_xml
    from {{ ref('stg_match') }}
    where foulcommit is not null
),

foul_events as (
    select 
        match_id,
        event.value as foul_event
    from matches,
    lateral flatten(
        input => get(matches.foul_xml, '$')
    ) as event

    where get(event.value, '@')::string = 'value' 
)

select 
    match_id,

    get(
        xmlget(foul_event, 'id'),
        '$'
    )::integer as foul_id,

    get(
        xmlget(foul_event, 'elapsed'),
        '$'
    )::integer as foul_minute,

    get(
        xmlget(foul_event, 'elapsed_plus'),
        '$'
    )::integer as stoppage_time,

    case 
        when get(xmlget(foul_event, 'elapsed'), '$') <= 45 
            then 'First Half'
        else 'Second Half'
    end as match_half,

    get(
        xmlget(foul_event, 'subtype'),
        '$'
    )::string as foul_subtype,

    try_to_number(
        get(
            xmlget(foul_event, 'player1'),
            '$'
        )::string
    ) as foul_committed_player_api_id,

    try_to_number(
        get(
            xmlget(foul_event, 'player2'),
            '$'
        )::string
    ) as fouled_player_api_id,

    get(
        xmlget(foul_event, 'sortorder'),
        '$'
    )::integer as foul_order,

    try_to_number(
        get(
            xmlget(foul_event, 'team'),
            '$'
        )::string
    ) as team_api_id,

    get(
        xmlget(foul_event, 'event_incident_typefk'),
        '$'
    )::integer as incident_type_id,

    'FOUL' as event_attribute 

from foul_events
where xmlget(foul_event, 'elapsed') is not null

  
