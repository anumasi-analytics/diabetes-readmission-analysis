USE diabetes_db;

SELECT
    age_group,
    COUNT(*)                          AS total_patients,
    SUM(readmitted_30)                AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY age_group
ORDER BY age_group;


-- Query 2: 30-day readmission rate by number of prior visits
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
SELECT
    stay_group,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY stay_group
ORDER BY MIN(time_in_hospital);


-- Query 4: 30-day readmission rate by medication change
SELECT
    `change`                           AS medication_change,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY `change`
ORDER BY `change`;


-- Query 5: 30-day readmission rate by primary diagnosis group
SELECT
    diag_group,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY diag_group
ORDER BY readmission_rate_pct DESC;


-- Query 6: 30-day readmission rate by A1C test result
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
SELECT
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct,
    ROUND(AVG(time_in_hospital), 2)    AS avg_stay_days,
    ROUND(AVG(num_medications), 1)     AS avg_medications
FROM diabetes_encounters;


-- Query 9: 30-day readmission rate by admission type
SELECT
    admission_type,
    COUNT(*)                           AS total_patients,
    SUM(readmitted_30)                 AS readmitted_30_count,
    ROUND(AVG(readmitted_30) * 100, 2) AS readmission_rate_pct
FROM diabetes_encounters
GROUP BY admission_type
ORDER BY readmission_rate_pct DESC;