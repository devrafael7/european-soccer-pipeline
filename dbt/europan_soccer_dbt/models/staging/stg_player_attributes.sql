with source as(
    select * 
    from {{ source('raw', 'player_attributes') }}
),

renamed as(
    select 
        ID::integer as player_atb_id,
        PLAYER_FIFA_API_ID::integer as PLAYER_FIFA_API_ID,
        PLAYER_API_ID::integer as PLAYER_API_ID,
        DATE as last_atb_update_date,
        OVERALL_RATING,
        POTENTIAL,
        PREFERRED_FOOT,
        ATTACKING_WORK_RATE,
        DEFENSIVE_WORK_RATE,
        CROSSING,
        FINISHING,
        HEADING_ACCURACY,
        SHORT_PASSING,
        VOLLEYS,
        DRIBBLING,
        CURVE,
        FREE_KICK_ACCURACY,
        LONG_PASSING,
        BALL_CONTROL,
        ACCELERATION,
        SPRINT_SPEED,
        AGILITY,
        REACTIONS,
        BALANCE,
        SHOT_POWER,
        JUMPING,
        STAMINA,
        STRENGTH,
        LONG_SHOTS,
        AGGRESSION,
        INTERCEPTIONS,
        POSITIONING,
        VISION,
        PENALTIES,
        MARKING,
        STANDING_TACKLE,
        SLIDING_TACKLE,
        GK_DIVING,
        GK_HANDLING,
        GK_KICKING,
        GK_POSITIONING,
        GK_REFLEXES
    from source

)

select * 
from renamed




