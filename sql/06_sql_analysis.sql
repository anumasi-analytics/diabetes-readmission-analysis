-- =====================================================================
-- File    : 06_sql_analysis.sql
-- Project : 30-Day Readmission Analysis Among Diabetic Patients
-- Purpose : SQL analysis of 30-day hospital readmission.
-- Table   : diabetes_encounters (69,979 patients, one row per patient)
-- Order   : 1) run 00_schema.sql  2) load data (python/05_load_mysql.py)
--           3) run this file
--
-- Key column:
--   readmitted_30 = 1 if the patient was readmitted within 30 days, else 0.
--   So AVG(readmitted_30) * 100 = the 30-day readmission rate in %.
--
-- Every result below was compared with the Power BI dashboard and matched.
-- =====================================================================

USE diabetes_db;


-- =====================================================================
-- SECTION A: DATA CHECKS (run these first to confirm the data loaded correctly)
-- =====================================================================

-- Check A: total rows. Expected: 69979
SELECT COUNT(*) AS total_rows
FROM diabetes_encounters;

-- Check B: each patient should appear only once.
-- Expected: total_patients and distinct_patients are both 69979
SELECT
    COUNT(*)                     AS total_patients,
    COUNT(DISTINCT patient_nbr)  AS distinct_patients
FROM diabetes_encounters;

-- Check C: the target column must contain only 0 and 1 (no NULL values).
-- Expected: exactly 2 rows (0 and 1). A third row with NULL would mean missing values.
SELECT
    readmitted_30,
    COUNT(*) AS patients
FROM diabetes_encounters
GROUP BY readmitted_30;


-- =====================================================================
-- SECTION B: ANALYSIS QUERIES (the 9 queries that answer the business questions)
-- =====================================================================

-- Query 1: 30-day readmission rate by age group
-- Business question: do older patients return to hospital more often?
-- Result: the rate rises with age, from 6.19% (0-29) to 10.62% (80+).
SELECT
    age_group,
    COUNT(*)                          AS total_patients,
    SUM(readmitted_30)                AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY age_group
ORDER BY age_group;


-- Query 2: 30-day readmission rate by number of prior visits
-- Business question: are patients who visited the hospital often last year more likely to return?
-- Result: this is the strongest factor, from 7.94% (0 visits) to 18.00% (6+ visits).
SELECT
    CASE WHEN prior_visits >= 6 THEN '6+'
         ELSE CAST(prior_visits AS CHAR)
    END                                AS prior_visits_group,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY prior_visits_group
ORDER BY MIN(prior_visits);


-- Query 3: 30-day readmission rate by length of hospital stay
-- Business question: do longer stays mean a higher chance of coming back?
-- Result: the rate rises from 7.53% (1-3 days) to 11.79% (8+ days).
SELECT
    stay_group,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY stay_group
ORDER BY MIN(time_in_hospital);


-- Query 4: 30-day readmission rate by medication change
-- Business question: does changing a diabetes medicine during the stay matter?
-- Result: small difference, 9.44% (changed) vs 8.60% (no change).
SELECT
    `change`                           AS medication_change,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY `change`
ORDER BY `change`;


-- Query 5: 30-day readmission rate by primary diagnosis group
-- Business question: which main diagnoses are linked to more readmissions?
-- Result: Injury is highest (10.80%), Respiratory is lowest (7.30%).
SELECT
    diag_group,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY diag_group
ORDER BY readmission_rate_pct DESC;


-- Query 6: 30-day readmission rate by A1C test result
-- Business question: does A1C testing relate to readmission, and how many patients were tested?
-- Result: 81.65% of patients had no A1C test, and this group has the highest rate (9.11%).
SELECT
    A1Cresult,
    COUNT(*)                                             AS total_patients,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)   AS pct_of_all_patients,
    SUM(readmitted_30)                                   AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2)                   AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY A1Cresult
ORDER BY readmission_rate_pct DESC;


-- Query 7: 30-day readmission rate by combined risk segment
-- Business question: can two simple factors (prior visits and length of stay) find the patients who need extra attention?
-- Rule: High = 3+ prior visits AND 8+ days. Medium = only one of the two. Lower = neither.
-- Result: High 17.42% (683 patients), Medium 12.13% (13,109), Lower 8.14% (56,187).
-- Note: this is a rule-based grouping, not a prediction model.
SELECT
    CASE
        WHEN prior_visits >= 3 AND time_in_hospital >= 8 THEN '1 - High risk (3+ prior visits and 8+ days)'
        WHEN prior_visits >= 3 OR  time_in_hospital >= 8 THEN '2 - Medium risk (one of the two)'
        ELSE '3 - Lower risk (neither)'
    END                                AS risk_segment,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY risk_segment
ORDER BY risk_segment;


-- Query 8: overall summary (KPI numbers for the dashboard)
-- Business question: what is the overall picture?
-- Result: 69,979 patients, 6,283 readmitted within 30 days, an overall rate of 8.98%.
SELECT
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct,
    ROUND(AVG(time_in_hospital), 2)    AS avg_stay_days,
    ROUND(AVG(num_medications), 1)     AS avg_medications
FROM diabetes_encounters;


-- Query 9: 30-day readmission rate by admission type
-- Business question: does the way the patient was admitted matter?
-- Result: a weak factor, only 8.29% to 9.29% across the admission types.
SELECT
    admission_type,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY admission_type
ORDER BY readmission_rate_pct DESC;
