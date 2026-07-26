with matches as(
    select 
        match_id,
        parse_xml(corner) as corner_xml
    from {{ ref('stg_match') }}
    where corner is not null
),

corner_events as (
    select 
        match_id,
        event.value as corner_event
    from matches,
    lateral flatten(
        input => get(matches.corner_xml, '$')
    ) as event

    where get(event.value, '@')::string = 'value' 
)

select 
    match_id,

    get(
        xmlget(corner_event, 'id'),
        '$'
    )::integer as corner_id,

    get(
        xmlget(corner_event, 'elapsed'),
        '$'
    )::integer as corner_minute,

    get(
        xmlget(corner_event, 'elapsed_plus'),
        '$'
    )::integer as stoppage_time,

    case 
        when get(xmlget(corner_event, 'elapsed'), '$') <= 45 
            then 'First Half'
        else 'Second Half'
    end as match_half,

    try_to_number(
        get(
            xmlget(corner_event, 'player1'),
            '$'
        )::string 
    ) as corner_kicker_player_api_id,

    get(
        xmlget(corner_event, 'sortorder'),
        '$'
    )::integer as corner_order,

    get(
        xmlget(corner_event, 'subtype'),
        '$'
    )::string as corner_subtype,

    try_to_number(
        get(
            xmlget(corner_event, 'team'),
            '$'
        )::string
    ) as team_api_id,

    get(
        xmlget(corner_event, 'event_incident_typefk'),
        '$'
    )::integer as incident_type_id,

    'CORNER' as event_attribute 

from corner_events
where xmlget(corner_event, 'elapsed') is not null

  