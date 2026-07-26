with matches as (

    select
        match_id,
        parse_xml(card) as card_xml
    from {{ ref('stg_match') }}
    where card is not null

),

card_events as (

    select
        matches.match_id,
        event.value as card_event
    from matches,
    lateral flatten(
        input => get(matches.card_xml, '$')
    ) as event

    where get(event.value, '@')::string = 'value'

)

select
    match_id,

    get(
        xmlget(card_event, 'id'),
        '$'
    )::integer as card_id,


    get(
        xmlget(card_event, 'elapsed'),
        '$'
    )::integer as card_minute,

    get(
        xmlget(card_event, 'elapsed_plus'),
        '$'
    )::integer as stoppage_time,

    case 
        when get(xmlget(card_event, 'elapsed'), '$') <= 45 
            then 'First Half'
        else 'Second Half'
    end as match_half,

    try_to_number(
        get(
            xmlget(card_event, 'player1'),
            '$'
        )::string  
    ) as card_received_player_api_id,

    case 
        when get(xmlget(card_event, 'card_type'), '$')::string = 'y'
            then 'Yellow Card'
        when get(xmlget(card_event, 'card_type'), '$')::string = 'r'
            then 'Red Card'
        when get(xmlget(card_event, 'card_type'), '$')::string = 'y2'
            then 'Second Yellow Card'
        else null
    end as card_type,

     case 
        when get(xmlget(card_event, 'card_type'), '$')::string in ('r', 'y2')
            then true
        else false
    end as is_sent_off,

    try_to_number(
        get(
            xmlget(card_event, 'team'),
            '$'
        )::string 
    ) as team_api_id,

    get(
        xmlget(card_event, 'subtype'),
        '$'
    )::string as foul_type,

    get(
        xmlget(card_event, 'event_incident_typefk'),
        '$'
    )::integer as incident_type_id,


    'CARD' as event_attribute

from card_events

where xmlget(card_event, 'elapsed') is not null