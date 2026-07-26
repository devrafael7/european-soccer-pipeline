with matches as(
    select 
        match_id,
        parse_xml(possession) as possession_xml
    from {{ ref('stg_match') }}
    where possession is not null
),

possession_events as (
    select 
        match_id,
        event.value as possession_event
    from matches,
    lateral flatten(
        input => get(matches.possession_xml, '$')
    ) as event

    where get(event.value, '@')::string = 'value' 
)

select 
    match_id,

    get(
        xmlget(possession_event, 'id'),
        '$'
    )::integer as possession_id,

    get(
        xmlget(possession_event, 'elapsed'),
        '$'
    )::integer as possession_minute,

    get(
        xmlget(possession_event, 'elapsed_plus'),
        '$'
    )::integer as stoppage_time,

    case 
        when get(xmlget(possession_event, 'elapsed'), '$') <= 45 
            then 'First Half'
        else 'Second Half'
    end as match_half,

    get(
        xmlget(possession_event, 'homepos'),
        '$'
    )::integer as home_possession,

    get(
        xmlget(possession_event, 'awaypos'),
        '$'
    )::integer as away_possession,

    get(
        xmlget(possession_event, 'sortorder'),
        '$'
    )::integer as possession_order,

    get(
        xmlget(possession_event, 'event_incident_typefk'),
        '$'
    )::integer as incident_type_id,

    'POSSESSION' as event_attribute

from possession_events
where xmlget(possession_event, 'elapsed') is not null

  