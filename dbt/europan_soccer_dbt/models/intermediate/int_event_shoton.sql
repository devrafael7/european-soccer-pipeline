with matches as(
    select 
        match_id,
        parse_xml(shoton) as shoton_xml
    from {{ ref('stg_match') }}
    where shoton is not null
),

shoton_events as (
    select 
        match_id,
        event.value as shoton_event
    from matches,
    lateral flatten(
        input => get(matches.shoton_xml, '$')
    ) as event

    where get(event.value, '@')::string = 'value' 
)

select 
    match_id,

    get(
        xmlget(shoton_event, 'id'),
        '$'
    )::integer as shoton_id,

    get(
        xmlget(shoton_event, 'elapsed'),
        '$'
    )::integer as shoton_minute,

    get(
        xmlget(shoton_event, 'elapsed_plus'),
        '$'
    )::integer as stoppage_time,

    case 
        when get(xmlget(shoton_event, 'elapsed'), '$') <= 45 
            then 'First Half'
        else 'Second Half'
    end as match_half,

    get(
        xmlget(shoton_event, 'subtype'),
        '$'
    )::string as shoton_subtype,

    try_to_number(
        get(
            xmlget(shoton_event, 'player1'),
            '$'
        )::string
    ) as kicker_api_id,

    get(
        xmlget(shoton_event, 'sortorder'),
        '$'
    )::integer as shoton_order,

    try_to_number(
        get(
            xmlget(shoton_event, 'team'),
            '$'
        )::string
    ) as team_api_id,

    get(
        xmlget(shoton_event, 'type'),
        '$'
    )::string as shoton_type,

    get(
        xmlget(shoton_event, 'event_incident_typefk'),
        '$'
    )::integer as incident_type_id,

    'SHOT_ON' as event_attribute

from shoton_events
where xmlget(shoton_event, 'elapsed') is not null

  
