with matches as(
    select 
        match_id,
        parse_xml(cross) as cross_xml
    from {{ ref('stg_match') }}
    where cross is not null
),

cross_events as (
    select 
        match_id,
        event.value as cross_event
    from matches,
    lateral flatten(
        input => get(matches.cross_xml, '$')
    ) as event

    where get(event.value, '@')::string = 'value' 
)

select 
    match_id,

    get(
        xmlget(cross_event, 'id'),
        '$'
    )::integer as cross_id,

    get(
        xmlget(cross_event, 'elapsed'),
        '$'
    )::integer as cross_minute,

    get(
        xmlget(cross_event, 'elapsed_plus'),
        '$'
    )::integer as stoppage_time,

    case 
        when get(xmlget(cross_event, 'elapsed'), '$') <= 45 
            then 'First Half'
        else 'Second Half'
    end as match_half,

    try_to_number(
        get(
            xmlget(cross_event, 'player1'),
            '$'
        )::string
    ) as crosser_player_api_id,

    get(
        xmlget(cross_event, 'sortorder'),
        '$'
    )::integer as cross_order,

    try_to_number(
        get(
            xmlget(cross_event, 'team'),
            '$'
        )::string
    ) as team_api_id,

    get(
        xmlget(cross_event, 'event_incident_typefk'),
        '$'
    )::integer as incident_type_id,

    'CROSS' as event_attribute

from cross_events
where xmlget(cross_event, 'elapsed') is not null

  