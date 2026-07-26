with matches as(
    select 
        match_id,
        parse_xml(shotoff) as shotoff_xml
    from {{ ref('stg_match') }}
    where shotoff is not null
),

shotoff_events as (
    select 
        match_id,
        event.value as shotoff_event
    from matches,
    lateral flatten(
        input => get(matches.shotoff_xml, '$')
    ) as event

    where get(event.value, '@')::string = 'value' 
)

select 
    match_id,

    get(
        xmlget(shotoff_event, 'id'),
        '$'
    )::integer as shotoff_id,

    get(
        xmlget(shotoff_event, 'elapsed'),
        '$'
    )::integer as shotoff_minute,

    get(
        xmlget(shotoff_event, 'elapsed_plus'),
        '$'
    )::integer as stoppage_time,

    case 
        when get(xmlget(shotoff_event, 'elapsed'), '$') <= 45 
            then 'First Half'
        else 'Second Half'
    end as match_half,

    get(
        xmlget(shotoff_event, 'subtype'),
        '$'
    )::string as shotoff_subtype,

    try_to_number(
        get(
            xmlget(shotoff_event, 'player1'),
            '$'
        )::string
    ) as kicker_api_id,

    get(
        xmlget(shotoff_event, 'sortorder'),
        '$'
    )::integer as shotoff_order,

    try_to_number(
        get(
            xmlget(shotoff_event, 'team'),
            '$'
        )::string
    ) as team_api_id,

    get(
        xmlget(shotoff_event, 'type'),
        '$'
    )::string as shotoff_type,

    get(
        xmlget(shotoff_event, 'event_incident_typefk'),
        '$'
    )::integer as incident_type_id,

    'SHOT_OFF' as event_attribute

from shotoff_events
where xmlget(shotoff_event, 'elapsed') is not null

  
