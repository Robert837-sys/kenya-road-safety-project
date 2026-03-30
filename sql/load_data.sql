-- ============================================================
-- FILE        : load_data.sql
-- PROJECT     : Kenya Road Accident Analytics & Risk Prediction
-- DESCRIPTION : Scripts to load CSV data into PostgreSQL
-- NOTE        : Python (SQLAlchemy) handles the actual bulk
--               loading. These scripts verify and supplement
--               the loading process.
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- STEP 1: Verify raw data was loaded by Python
-- Run after 01_load_data.ipynb
-- ────────────────────────────────────────────────────────────
SELECT
    'accidents_raw'       AS table_name,
    COUNT(*)              AS total_records,
    COUNT(county)         AS non_null_county,
    COUNT(cause_code)     AS non_null_cause,
    MIN(accident_date)    AS earliest_date,
    MAX(accident_date)    AS latest_date
FROM accidents_raw;

-- ────────────────────────────────────────────────────────────
-- STEP 2: Verify cleaned data was loaded by Python
-- Run after 02_clean_data.ipynb
-- ────────────────────────────────────────────────────────────
SELECT
    'accidents_clean'          AS table_name,
    COUNT(*)                   AS total_records,
    COUNT(DISTINCT county)     AS unique_counties,
    COUNT(DISTINCT road)       AS unique_roads,
    SUM(is_fatal)              AS total_fatalities,
    ROUND(AVG(is_fatal)*100,1) AS fatality_rate_pct,
    SUM(num_victims)           AS total_victims
FROM accidents_clean;

-- ────────────────────────────────────────────────────────────
-- STEP 3: Verify county risk clusters were loaded by Python
-- Run after 08_kmeans.ipynb
-- ────────────────────────────────────────────────────────────
SELECT
    risk_level,
    COUNT(*)             AS county_count,
    SUM(total_accidents) AS total_accidents,
    ROUND(AVG(fatality_rate),2) AS avg_fatality_rate
FROM county_risk_clusters
GROUP BY risk_level
ORDER BY
    CASE risk_level
        WHEN 'High Risk'   THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk'    THEN 3
    END;

-- ────────────────────────────────────────────────────────────
-- STEP 4: Quick data quality check
-- ────────────────────────────────────────────────────────────
SELECT
    'Missing county'         AS check_name,
    COUNT(*)                 AS count
FROM accidents_clean
WHERE county IS NULL

UNION ALL

SELECT
    'Missing cause_code',
    COUNT(*)
FROM accidents_clean
WHERE cause_code IS NULL

UNION ALL

SELECT
    'Missing victim_category',
    COUNT(*)
FROM accidents_clean
WHERE victim_category IS NULL

UNION ALL

SELECT
    'Missing is_fatal',
    COUNT(*)
FROM accidents_clean
WHERE is_fatal IS NULL

UNION ALL

SELECT
    'Invalid is_fatal (not 0 or 1)',
    COUNT(*)
FROM accidents_clean
WHERE is_fatal NOT IN (0, 1);
