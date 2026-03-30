-- ============================================================
-- FILE        : queries.sql
-- PROJECT     : Kenya Road Accident Analytics & Risk Prediction
-- DESCRIPTION : 15 analytical SQL queries answering all
--               research questions for the project
-- DATABASE    : PostgreSQL 15 | Table: accidents_clean
-- ============================================================


-- ════════════════════════════════════════════════════════════
-- QUERY 1: Total accidents, fatalities and victims overview
-- Answers: Project overview statistics
-- ════════════════════════════════════════════════════════════
SELECT
    COUNT(*)                          AS total_accidents,
    SUM(is_fatal)                     AS total_fatalities,
    SUM(num_victims)                  AS total_victims,
    ROUND(AVG(is_fatal) * 100, 2)     AS fatality_rate_pct,
    ROUND(AVG(num_victims), 2)        AS avg_victims_per_accident,
    COUNT(DISTINCT county)            AS unique_counties,
    COUNT(DISTINCT road)              AS unique_roads
FROM accidents_clean;


-- ════════════════════════════════════════════════════════════
-- QUERY 2: Top 10 counties by number of accidents
-- Answers: RQ1 — Which counties have the most accidents?
-- ════════════════════════════════════════════════════════════
SELECT
    county,
    COUNT(*)                             AS total_accidents,
    SUM(is_fatal)                        AS total_fatalities,
    SUM(num_victims)                     AS total_victims,
    ROUND(AVG(is_fatal) * 100, 2)        AS fatality_rate_pct,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2
    )                                    AS pct_of_total
FROM accidents_clean
WHERE county IS NOT NULL
GROUP BY county
ORDER BY total_accidents DESC
LIMIT 10;


-- ════════════════════════════════════════════════════════════
-- QUERY 3: Accidents by time of day
-- Answers: RQ2 — When are accidents most frequent?
-- ════════════════════════════════════════════════════════════
SELECT
    time_of_day,
    COUNT(*)                          AS total_accidents,
    SUM(is_fatal)                     AS total_fatalities,
    SUM(num_victims)                  AS total_victims,
    ROUND(AVG(is_fatal) * 100, 2)     AS fatality_rate_pct,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2
    )                                 AS pct_of_total
FROM accidents_clean
GROUP BY time_of_day
ORDER BY total_accidents DESC;


-- ════════════════════════════════════════════════════════════
-- QUERY 4: Accidents by hour of day (24-hour breakdown)
-- Answers: RQ2 — Detailed hourly accident distribution
-- ════════════════════════════════════════════════════════════
SELECT
    hour,
    COUNT(*)                      AS total_accidents,
    SUM(is_fatal)                 AS total_fatalities,
    ROUND(AVG(is_fatal)*100, 2)   AS fatality_rate_pct
FROM accidents_clean
WHERE hour IS NOT NULL
GROUP BY hour
ORDER BY hour;


-- ════════════════════════════════════════════════════════════
-- QUERY 5: Top 10 accident cause codes
-- Answers: RQ3 — What are the leading causes of accidents?
-- ════════════════════════════════════════════════════════════
SELECT
    cause_code,
    COUNT(*)                          AS total_accidents,
    SUM(is_fatal)                     AS total_fatalities,
    ROUND(AVG(is_fatal) * 100, 2)     AS fatality_rate_pct,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2
    )                                 AS pct_of_total
FROM accidents_clean
WHERE cause_code IS NOT NULL
GROUP BY cause_code
ORDER BY total_accidents DESC
LIMIT 10;


-- ════════════════════════════════════════════════════════════
-- QUERY 6: Accidents and fatalities by victim category
-- Answers: RQ4 — Which victim types are most at risk?
-- ════════════════════════════════════════════════════════════
SELECT
    victim_category,
    COUNT(*)                          AS total_accidents,
    SUM(is_fatal)                     AS total_fatalities,
    SUM(num_victims)                  AS total_victims,
    ROUND(AVG(is_fatal) * 100, 2)     AS fatality_rate_pct,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2
    )                                 AS pct_of_total
FROM accidents_clean
GROUP BY victim_category
ORDER BY total_accidents DESC;


-- ════════════════════════════════════════════════════════════
-- QUERY 7: Accidents by gender
-- Answers: RQ5 — What are the gender patterns?
-- ════════════════════════════════════════════════════════════
SELECT
    gender_clean,
    COUNT(*)                          AS total_accidents,
    SUM(is_fatal)                     AS total_fatalities,
    ROUND(AVG(is_fatal) * 100, 2)     AS fatality_rate_pct,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2
    )                                 AS pct_of_total
FROM accidents_clean
GROUP BY gender_clean
ORDER BY total_accidents DESC;


-- ════════════════════════════════════════════════════════════
-- QUERY 8: Accidents by age group
-- Answers: RQ5 — What are the age group patterns?
-- ════════════════════════════════════════════════════════════
SELECT
    age_group,
    COUNT(*)                          AS total_accidents,
    SUM(is_fatal)                     AS total_fatalities,
    SUM(num_victims)                  AS total_victims,
    ROUND(AVG(is_fatal) * 100, 2)     AS fatality_rate_pct
FROM accidents_clean
GROUP BY age_group
ORDER BY total_accidents DESC;


-- ════════════════════════════════════════════════════════════
-- QUERY 9: Top 10 most dangerous roads
-- Answers: RQ1 — Which roads have the most accidents?
-- ════════════════════════════════════════════════════════════
SELECT
    road,
    COUNT(*)                          AS total_accidents,
    SUM(is_fatal)                     AS total_fatalities,
    SUM(num_victims)                  AS total_victims,
    ROUND(AVG(is_fatal) * 100, 2)     AS fatality_rate_pct
FROM accidents_clean
WHERE road IS NOT NULL
GROUP BY road
ORDER BY total_accidents DESC
LIMIT 10;


-- ════════════════════════════════════════════════════════════
-- QUERY 10: Fatality rate by county (min 5 accidents)
-- Answers: RQ6 — Which counties have highest fatality rates?
-- ════════════════════════════════════════════════════════════
SELECT
    county,
    COUNT(*)                          AS total_accidents,
    SUM(is_fatal)                     AS total_fatalities,
    ROUND(AVG(is_fatal) * 100, 2)     AS fatality_rate_pct
FROM accidents_clean
WHERE county IS NOT NULL
GROUP BY county
HAVING COUNT(*) >= 5
ORDER BY fatality_rate_pct DESC
LIMIT 15;


-- ════════════════════════════════════════════════════════════
-- QUERY 11: Fatal vs non-fatal by victim type and time of day
-- Answers: RQ7 — What factors correlate with fatality?
-- Uses: WINDOW FUNCTION + CASE
-- ════════════════════════════════════════════════════════════
SELECT
    victim_category,
    time_of_day,
    COUNT(*)                                   AS total_accidents,
    SUM(is_fatal)                              AS total_fatalities,
    ROUND(AVG(is_fatal) * 100, 2)              AS fatality_rate_pct,
    RANK() OVER (
        PARTITION BY victim_category
        ORDER BY SUM(is_fatal) DESC
    )                                          AS rank_by_fatalities
FROM accidents_clean
WHERE victim_category IS NOT NULL
  AND time_of_day IS NOT NULL
GROUP BY victim_category, time_of_day
ORDER BY victim_category, total_fatalities DESC;


-- ════════════════════════════════════════════════════════════
-- QUERY 12: County risk classification summary
-- Answers: RQ10 — County risk tier distribution
-- Uses: JOIN with county_risk_clusters
-- ════════════════════════════════════════════════════════════
SELECT
    cr.risk_level,
    cr.county,
    cr.total_accidents,
    cr.total_fatalities,
    cr.fatality_rate,
    cr.night_rate,
    cr.latitude,
    cr.longitude
FROM county_risk_clusters cr
ORDER BY
    CASE cr.risk_level
        WHEN 'High Risk'   THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk'    THEN 3
    END,
    cr.total_accidents DESC;


-- ════════════════════════════════════════════════════════════
-- QUERY 13: Accident trends by county and time of day
-- Uses: CTE (Common Table Expression)
-- ════════════════════════════════════════════════════════════
WITH county_time_summary AS (
    SELECT
        county,
        time_of_day,
        COUNT(*)              AS accidents,
        SUM(is_fatal)         AS fatalities,
        SUM(num_victims)      AS victims
    FROM accidents_clean
    WHERE county IS NOT NULL
      AND time_of_day != 'Unknown'
    GROUP BY county, time_of_day
),
county_totals AS (
    SELECT
        county,
        SUM(accidents)        AS total_county_accidents
    FROM county_time_summary
    GROUP BY county
)
SELECT
    cts.county,
    cts.time_of_day,
    cts.accidents,
    cts.fatalities,
    ROUND(
        cts.accidents * 100.0 / ct.total_county_accidents,
        2
    )                         AS pct_of_county_accidents
FROM county_time_summary cts
JOIN county_totals ct
  ON cts.county = ct.county
WHERE ct.total_county_accidents >= 10
ORDER BY cts.county, cts.accidents DESC;


-- ════════════════════════════════════════════════════════════
-- QUERY 14: Running total of accidents by hour (cumulative)
-- Uses: WINDOW FUNCTION (cumulative sum)
-- ════════════════════════════════════════════════════════════
SELECT
    hour,
    COUNT(*)                                AS accidents_this_hour,
    SUM(is_fatal)                           AS fatalities_this_hour,
    SUM(COUNT(*)) OVER (
        ORDER BY hour
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    )                                       AS cumulative_accidents,
    ROUND(
        SUM(COUNT(*)) OVER (
            ORDER BY hour
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    )                                       AS cumulative_pct
FROM accidents_clean
WHERE hour IS NOT NULL
GROUP BY hour
ORDER BY hour;


-- ════════════════════════════════════════════════════════════
-- QUERY 15: High risk accident combinations
-- Answers: RQ8 — Which conditions most predict fatality?
-- Uses: CASE + GROUP BY + HAVING + ORDER BY
-- ════════════════════════════════════════════════════════════
SELECT
    county,
    time_of_day,
    victim_category,
    cause_code,
    COUNT(*)                              AS total_accidents,
    SUM(is_fatal)                         AS total_fatalities,
    ROUND(AVG(is_fatal) * 100, 2)         AS fatality_rate_pct,
    CASE
        WHEN AVG(is_fatal) >= 0.30 THEN 'CRITICAL RISK'
        WHEN AVG(is_fatal) >= 0.20 THEN 'HIGH RISK'
        WHEN AVG(is_fatal) >= 0.10 THEN 'MEDIUM RISK'
        ELSE                            'LOW RISK'
    END                                   AS risk_category,
    SUM(num_victims)                      AS total_victims
FROM accidents_clean
WHERE county IS NOT NULL
  AND time_of_day IS NOT NULL
  AND victim_category IS NOT NULL
  AND cause_code IS NOT NULL
GROUP BY county, time_of_day, victim_category, cause_code
HAVING COUNT(*) >= 3
ORDER BY fatality_rate_pct DESC, total_accidents DESC
LIMIT 20;
