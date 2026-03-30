-- ============================================================
-- FILE        : create_tables.sql
-- PROJECT     : Kenya Road Accident Analytics & Risk Prediction
-- DESCRIPTION : Complete database schema for kenya_road_safety
-- DATABASE    : PostgreSQL 15
-- ============================================================

-- Create database (run this separately if needed)
-- CREATE DATABASE kenya_road_safety;

-- Connect to database
-- \c kenya_road_safety

-- ────────────────────────────────────────────────────────────
-- DROP EXISTING TABLES (clean setup)
-- ────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS accidents_clean   CASCADE;
DROP TABLE IF EXISTS accidents_raw     CASCADE;
DROP TABLE IF EXISTS county_risk_clusters CASCADE;

-- ────────────────────────────────────────────────────────────
-- TABLE 1: accidents_raw
-- Staging table — raw CSV data loaded directly from NTSA file
-- ────────────────────────────────────────────────────────────
CREATE TABLE accidents_raw (
    id               SERIAL PRIMARY KEY,
    time_24hrs       VARCHAR(20),
    base             VARCHAR(100),
    county           VARCHAR(100),
    road             VARCHAR(200),
    place            VARCHAR(200),
    mv_involved      TEXT,
    accident_details TEXT,
    victim_name      VARCHAR(200),
    gender           VARCHAR(30),
    age              VARCHAR(20),
    cause_code       VARCHAR(20),
    victim_type      VARCHAR(100),
    num_victims      VARCHAR(10),
    accident_date    VARCHAR(20)
);

COMMENT ON TABLE accidents_raw IS
    'Staging table holding raw NTSA accident CSV data before cleaning';

-- ────────────────────────────────────────────────────────────
-- TABLE 2: accidents_clean
-- Main analytical table — cleaned and feature-engineered data
-- ────────────────────────────────────────────────────────────
CREATE TABLE accidents_clean (
    id               SERIAL PRIMARY KEY,

    -- Time features
    time             NUMERIC,
    hour             INTEGER,
    time_of_day      VARCHAR(20)
                     CHECK (time_of_day IN (
                         'Morning', 'Afternoon',
                         'Evening', 'Night', 'Unknown'
                     )),

    -- Location features
    base             VARCHAR(100),
    county           VARCHAR(100),
    road             VARCHAR(200),
    place            VARCHAR(200),

    -- Vehicle information
    mv_involved      TEXT,

    -- Accident details
    accident_details TEXT,
    victim_name      VARCHAR(200),

    -- Victim demographics (raw)
    gender           VARCHAR(30),
    age              VARCHAR(20),

    -- Victim demographics (cleaned)
    gender_clean     VARCHAR(20)
                     CHECK (gender_clean IN (
                         'Male', 'Female',
                         'Multiple', 'Unknown'
                     )),
    age_group        VARCHAR(30)
                     CHECK (age_group IN (
                         'Juvenile', 'Young Adult', 'Adult',
                         'Middle Aged', 'Elderly',
                         'Multiple', 'Unknown'
                     )),

    -- Accident classification (raw)
    cause_code       VARCHAR(20),
    victim_type      VARCHAR(100),

    -- Accident classification (cleaned)
    victim_category  VARCHAR(30)
                     CHECK (victim_category IN (
                         'Motorcyclist', 'Pedestrian', 'Passenger',
                         'Driver', 'Cyclist', 'Other', 'Unknown'
                     )),

    -- Quantitative columns
    num_victims      INTEGER DEFAULT 1,

    -- Date
    accident_date    DATE,

    -- Target variable (engineered)
    is_fatal         INTEGER DEFAULT 0
                     CHECK (is_fatal IN (0, 1))
);

COMMENT ON TABLE accidents_clean IS
    'Main analytical table with cleaned and feature-engineered accident data';

COMMENT ON COLUMN accidents_clean.is_fatal IS
    '1 = fatal accident (based on keyword detection in accident_details), 0 = non-fatal';
COMMENT ON COLUMN accidents_clean.victim_category IS
    'Standardized victim type — reduced from 53 raw variants to 7 clean categories';
COMMENT ON COLUMN accidents_clean.time_of_day IS
    'Derived from hour: Morning=6-12, Afternoon=12-17, Evening=17-21, Night=otherwise';

-- ────────────────────────────────────────────────────────────
-- TABLE 3: county_risk_clusters
-- K-Means clustering output — county risk tiers
-- ────────────────────────────────────────────────────────────
CREATE TABLE county_risk_clusters (
    id               SERIAL PRIMARY KEY,
    county           VARCHAR(100) NOT NULL,
    total_accidents  INTEGER,
    total_fatalities INTEGER,
    total_victims    INTEGER,
    avg_victims      NUMERIC(6,2),
    fatality_rate    NUMERIC(6,2),
    night_rate       NUMERIC(6,2),
    night_accidents  INTEGER,
    morning_accidents INTEGER,
    evening_accidents INTEGER,
    cluster          INTEGER,
    risk_level       VARCHAR(20)
                     CHECK (risk_level IN (
                         'High Risk', 'Medium Risk', 'Low Risk'
                     )),
    latitude         NUMERIC(10,6),
    longitude        NUMERIC(10,6)
);

COMMENT ON TABLE county_risk_clusters IS
    'K-Means clustering results grouping 42 counties into High/Medium/Low risk tiers';

-- ────────────────────────────────────────────────────────────
-- INDEXES — for faster query performance
-- ────────────────────────────────────────────────────────────
CREATE INDEX idx_accidents_county
    ON accidents_clean(county);

CREATE INDEX idx_accidents_road
    ON accidents_clean(road);

CREATE INDEX idx_accidents_date
    ON accidents_clean(accident_date);

CREATE INDEX idx_accidents_is_fatal
    ON accidents_clean(is_fatal);

CREATE INDEX idx_accidents_time_of_day
    ON accidents_clean(time_of_day);

CREATE INDEX idx_accidents_victim_category
    ON accidents_clean(victim_category);

CREATE INDEX idx_accidents_cause_code
    ON accidents_clean(cause_code);

CREATE INDEX idx_county_risk_level
    ON county_risk_clusters(risk_level);

-- ────────────────────────────────────────────────────────────
-- VERIFICATION
-- ────────────────────────────────────────────────────────────
SELECT
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name)))
        AS total_size
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
