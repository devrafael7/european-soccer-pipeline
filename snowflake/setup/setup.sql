USE SCHEMA EUROPEAN_SOCCER_DB.RAW;

CREATE OR REPLACE TABLE COUNTRY(
    ID STRING,
    NAME STRING
);

CREATE OR REPLACE TABLE LEAGUE (
    ID STRING,
    COUNTRY_ID STRING,
    NAME STRING
);

CREATE OR REPLACE TABLE MATCH(
    id STRING,
    country_id STRING,
    league_id STRING,
    season STRING,
    stage STRING,
    date DATE,
    match_api_id STRING,
    home_team_api_id STRING,
    away_team_api_id STRING,
    home_team_goal DECIMAL(10,2),
    away_team_goal DECIMAL(10,2),
    home_player_X1 DECIMAL(10,2),
    home_player_X2 DECIMAL(10,2),
    home_player_X3 DECIMAL(10,2),
    home_player_X4 DECIMAL(10,2),
    home_player_X5 DECIMAL(10,2),
    home_player_X6 DECIMAL(10,2),
    home_player_X7 DECIMAL(10,2),
    home_player_X8 DECIMAL(10,2),
    home_player_X9 DECIMAL(10,2),
    home_player_X10 DECIMAL(10,2),
    home_player_X11 DECIMAL(10,2),
    away_player_X1 DECIMAL(10,2),
    away_player_X2 DECIMAL(10,2),
    away_player_X3 DECIMAL(10,2),
    away_player_X4 DECIMAL(10,2),
    away_player_X5 DECIMAL(10,2),
    away_player_X6 DECIMAL(10,2),
    away_player_X7 DECIMAL(10,2),
    away_player_X8 DECIMAL(10,2),
    away_player_X9 DECIMAL(10,2),
    away_player_X10 DECIMAL(10,2),
    away_player_X11 DECIMAL(10,2),
    home_player_Y1 DECIMAL(10,2),
    home_player_Y2 DECIMAL(10,2),
    home_player_Y3 DECIMAL(10,2),
    home_player_Y4 DECIMAL(10,2),
    home_player_Y5 DECIMAL(10,2),
    home_player_Y6 DECIMAL(10,2),
    home_player_Y7 DECIMAL(10,2),
    home_player_Y8 DECIMAL(10,2),
    home_player_Y9 DECIMAL(10,2),
    home_player_Y10 DECIMAL(10,2),
    home_player_Y11 DECIMAL(10,2),
    away_player_Y1 DECIMAL(10,2),
    away_player_Y2 DECIMAL(10,2),
    away_player_Y3 DECIMAL(10,2),
    away_player_Y4 DECIMAL(10,2),
    away_player_Y5 DECIMAL(10,2),
    away_player_Y6 DECIMAL(10,2),
    away_player_Y7 DECIMAL(10,2),
    away_player_Y8 DECIMAL(10,2),
    away_player_Y9 DECIMAL(10,2),
    away_player_Y10 DECIMAL(10,2),
    away_player_Y11 DECIMAL(10,2),
    home_player_1 STRING,
    home_player_2 STRING,
    home_player_3 STRING,
    home_player_4 STRING,
    home_player_5 STRING,
    home_player_6 STRING,
    home_player_7 STRING,
    home_player_8 STRING,
    home_player_9 STRING,
    home_player_10 STRING,
    home_player_11 STRING,
    away_player_1 STRING,
    away_player_2 STRING,
    away_player_3 STRING,
    away_player_4 STRING,
    away_player_5 STRING,
    away_player_6 STRING,
    away_player_7 STRING,
    away_player_8 STRING,
    away_player_9 STRING,
    away_player_10 STRING,
    away_player_11 STRING,
    goal STRING,
    shoton STRING,
    shotoff STRING,
    foulcommit STRING,
    card STRING,
    cross STRING,
    corner STRING,
    possession STRING,
    B365H DECIMAL (10, 2),
    B365D DECIMAL (10, 2),
    B365A DECIMAL (10, 2),
    BWH DECIMAL (10, 2),
    BWD DECIMAL (10, 2),
    BWA DECIMAL (10, 2),
    IWH DECIMAL (10, 2),
    IWD DECIMAL (10, 2),
    IWA DECIMAL (10, 2),
    LBH DECIMAL (10, 2),
    LBD DECIMAL (10, 2),
    LBA DECIMAL (10, 2),
    PSH DECIMAL (10, 2),
    PSD DECIMAL (10, 2),
    PSA DECIMAL (10, 2),
    WHH DECIMAL (10, 2),
    WHD DECIMAL (10, 2),
    WHA DECIMAL (10, 2),
    SJH DECIMAL (10, 2),
    SJD DECIMAL (10, 2),
    SJA DECIMAL (10, 2),
    VCH DECIMAL (10, 2),
    VCD DECIMAL (10, 2),
    VCA DECIMAL (10, 2),
    GBH DECIMAL (10, 2),
    GBD DECIMAL (10, 2),
    GBA DECIMAL (10, 2),
    BSH DECIMAL (10, 2),
    BSD DECIMAL (10, 2),
    BSA DECIMAL (10, 2)
);

CREATE OR REPLACE TABLE PLAYER(
    ID STRING,
    PLAYER_API_ID STRING,
    PLAYER_NAME STRING,
    PLAYER_FIFA_API_ID STRING,
    BIRTHDAY DATE,
    HEIGHT DECIMAL(10,2),
    WEIGHT DECIMAL(10,2)
);

CREATE OR REPLACE TABLE PLAYER_ATTRIBUTES(
    id STRING,
    player_fifa_api_id STRING,
    player_api_id STRING,
    date DATE,
    overall_rating DECIMAL(10,2),
    potential DECIMAL(10,2),
    preferred_foot STRING,
    attacking_work_rate STRING,
    defensive_work_rate STRING,
    crossing DECIMAL(10,2),
    finishing DECIMAL(10,2),
    heading_accuracy DECIMAL(10,2),
    short_passing DECIMAL(10,2),
    volleys DECIMAL(10,2),
    dribbling DECIMAL(10,2),
    curve DECIMAL(10,2),
    free_kick_accuracy DECIMAL(10,2),
    long_passing DECIMAL(10,2),
    ball_control DECIMAL(10,2),
    acceleration DECIMAL(10,2),
    sprint_speed DECIMAL(10,2),
    agility DECIMAL(10,2),
    reactions DECIMAL(10,2),
    balance DECIMAL(10,2),
    shot_power DECIMAL(10,2),
    jumping DECIMAL(10,2),
    stamina DECIMAL(10,2),
    strength DECIMAL(10,2),
    long_shots DECIMAL(10,2),
    aggression DECIMAL(10,2),
    interceptions DECIMAL(10,2),
    positioning DECIMAL(10,2),
    vision DECIMAL(10,2),
    penalties DECIMAL(10,2),
    marking DECIMAL(10,2),
    standing_tackle DECIMAL(10,2),
    sliding_tackle DECIMAL(10,2),
    gk_diving DECIMAL(10,2),
    gk_handling DECIMAL(10,2),
    gk_kicking DECIMAL(10,2),
    gk_positioning DECIMAL(10,2),
    gk_reflexes DECIMAL(10,2)
);

CREATE OR REPLACE TABLE TEAM(
    ID STRING,
    TEAM_API_ID STRING,
    TEAM_FIFA_API_ID STRING,
    TEAM_LONG_NAME STRING,
    TEAM_SHORT_NAME STRING
);

CREATE OR REPLACE TABLE TEAM_ATTRIBUTES(
    ID STRING,
    TEAM_FIFA_API_ID STRING,
    team_api_id STRING
);

CREATE OR REPLACE TABLE TEAM_ATTRIBUTES(
    id STRING,
    team_fifa_api_id STRING,
    team_api_id STRING,
    date DATE,
    buildUpPlaySpeed DECIMAL(10,2),
    buildUpPlaySpeedClass STRING,
    buildUpPlayDribbling DECIMAL(10,2),
    buildUpPlayDribblingClass STRING,
    buildUpPlayPassing DECIMAL(10,2),
    buildUpPlayPassingClass STRING,
    buildUpPlayPositioningClass STRING,
    chanceCreationPassing DECIMAL(10,2),
    chanceCreationPassingClass STRING,
    chanceCreationCrossing DECIMAL(10,2),
    chanceCreationCrossingClass STRING,
    chanceCreationShooting DECIMAL(10,2),
    chanceCreationShootingClass STRING,
    chanceCreationPositioningClass STRING,
    defencePressure DECIMAL(10,2),
    defencePressureClass STRING,
    defenceAggression DECIMAL(10,2),
    defenceAggressionClass STRING,
    defenceTeamWidth DECIMAL(10,2),
    defenceTeamWidthClass STRING,
    defenceDefenderLineClass STRING
);

USE DATABASE EUROPEAN_SOCCER_DB;

CREATE SCHEMA IF NOT EXISTS STAGING;
CREATE SCHEMA IF NOT EXISTS INTERMEDIATE;
CREATE SCHEMA IF NOT EXISTS MARTS;
DROP SCHEMA IF EXISTS SILVER;
DROP SCHEMA IF EXISTS GOLD;

DROP SCHEMA IF EXISTS RAW_STAGING;

USE SCHEMA RAW_STAGING;
DROP VIEW IF EXISTS STG_LEAGUE;
DROP VIEW IF EXISTS STG_COUNTRY;
DROP VIEW IF EXISTS STG_MATCH;
DROP VIEW IF EXISTS STG_PLAYER;
DROP VIEW IF EXISTS STG_PLAYER_ATTRIBUTES;
DROP VIEW IF EXISTS STG_TEAM;
DROP VIEW IF EXISTS STG_TEAM_ATTRIBUTES;

