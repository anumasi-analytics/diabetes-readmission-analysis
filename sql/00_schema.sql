-- =====================================================================
-- File    : 00_schema.sql
-- Project : 30-Day Readmission Analysis Among Diabetic Patients
-- Purpose : Creates the database and the table used by the project.
--           Run this file once BEFORE loading the data with
--           python/05_load_mysql.py (or Part G of the notebook).
-- Table   : diabetes_encounters  (one row per patient after cleaning,
--           69,979 rows, 55 columns)
-- Source  : Diabetes 130-US Hospitals for Years 1999-2008 (UCI, CC BY 4.0)
--           https://archive.ics.uci.edu/dataset/296/diabetes-130-us-hospitals-for-years-1999-2008
-- =====================================================================

-- 1. Create the database
CREATE DATABASE IF NOT EXISTS diabetes_db;
USE diabetes_db;

-- 2. (Optional) Create a project user. Choose your own password.
--    The Python script asks for this password when it runs, so it is
--    never stored in the code.
-- CREATE USER IF NOT EXISTS 'diabetes_user'@'localhost' IDENTIFIED BY 'choose-your-own-password';
-- GRANT ALL PRIVILEGES ON diabetes_db.* TO 'diabetes_user'@'localhost';
-- FLUSH PRIVILEGES;

-- 3. Create the table
CREATE TABLE IF NOT EXISTS `diabetes_encounters` (

  -- ---------- Identifiers ----------
  `encounter_id` int NOT NULL,                      -- unique id of the hospital encounter (primary key)
  `patient_nbr` int NOT NULL,                       -- patient id (one row per patient after cleaning)

  -- ---------- Patient details ----------
  `race` varchar(30) DEFAULT NULL,
  `gender` varchar(15) DEFAULT NULL,
  `age` varchar(15) DEFAULT NULL,                   -- original 10-year band, e.g. [60-70)

  -- ---------- Admission and stay ----------
  `admission_type_id` tinyint DEFAULT NULL,         -- 1 Emergency, 2 Urgent, 3 Elective, others = Other/Unknown
  `discharge_disposition_id` tinyint DEFAULT NULL,  -- where the patient went after discharge
  `admission_source_id` tinyint DEFAULT NULL,
  `time_in_hospital` tinyint DEFAULT NULL,          -- days in hospital (1-14)
  `payer_code` varchar(20) DEFAULT NULL,
  `medical_specialty` varchar(60) DEFAULT NULL,

  -- ---------- Tests, procedures and counts ----------
  `num_lab_procedures` smallint DEFAULT NULL,
  `num_procedures` tinyint DEFAULT NULL,
  `num_medications` smallint DEFAULT NULL,
  `number_outpatient` smallint DEFAULT NULL,        -- outpatient visits in the previous year
  `number_emergency` smallint DEFAULT NULL,         -- emergency visits in the previous year
  `number_inpatient` smallint DEFAULT NULL,         -- inpatient visits in the previous year

  -- ---------- Diagnoses (ICD-9 codes) ----------
  `diag_1` varchar(15) DEFAULT NULL,                -- primary diagnosis
  `diag_2` varchar(15) DEFAULT NULL,
  `diag_3` varchar(15) DEFAULT NULL,
  `number_diagnoses` tinyint DEFAULT NULL,

  -- ---------- Lab results ----------
  `max_glu_serum` varchar(20) DEFAULT NULL,         -- glucose serum test result ('Not Tested' if not done)
  `A1Cresult` varchar(20) DEFAULT NULL,             -- A1C test result ('Not Tested' if not done)

  -- ---------- Diabetes medicines (No / Steady / Up / Down) ----------
  `metformin` varchar(10) DEFAULT NULL,
  `repaglinide` varchar(10) DEFAULT NULL,
  `nateglinide` varchar(10) DEFAULT NULL,
  `chlorpropamide` varchar(10) DEFAULT NULL,
  `glimepiride` varchar(10) DEFAULT NULL,
  `acetohexamide` varchar(10) DEFAULT NULL,
  `glipizide` varchar(10) DEFAULT NULL,
  `glyburide` varchar(10) DEFAULT NULL,
  `tolbutamide` varchar(10) DEFAULT NULL,
  `pioglitazone` varchar(10) DEFAULT NULL,
  `rosiglitazone` varchar(10) DEFAULT NULL,
  `acarbose` varchar(10) DEFAULT NULL,
  `miglitol` varchar(10) DEFAULT NULL,
  `troglitazone` varchar(10) DEFAULT NULL,
  `tolazamide` varchar(10) DEFAULT NULL,
  `insulin` varchar(10) DEFAULT NULL,
  `glyburide-metformin` varchar(10) DEFAULT NULL,
  `glipizide-metformin` varchar(10) DEFAULT NULL,
  `glimepiride-pioglitazone` varchar(10) DEFAULT NULL,
  `metformin-rosiglitazone` varchar(10) DEFAULT NULL,
  `metformin-pioglitazone` varchar(10) DEFAULT NULL,

  -- ---------- Medication summary and outcome ----------
  `change` varchar(5) DEFAULT NULL,                 -- Ch = a medicine was changed, No = no change
  `diabetesMed` varchar(5) DEFAULT NULL,            -- any diabetes medicine prescribed (Yes / No)
  `readmitted` varchar(5) DEFAULT NULL,             -- <30, >30 or NO
  `readmitted_30` tinyint DEFAULT NULL,             -- TARGET: 1 = readmitted within 30 days, 0 = not

  -- ---------- Features created in Python (03_features.py) ----------
  `age_group` varchar(15) DEFAULT NULL,             -- 0-29, 30-59, 60-79, 80+
  `stay_group` varchar(30) DEFAULT NULL,            -- Short (1-3 days), Medium (4-7 days), Long (8+ days)
  `meds_active` tinyint DEFAULT NULL,               -- number of diabetes medicines the patient is on
  `meds_changed` tinyint DEFAULT NULL,              -- number of medicines changed up or down
  `prior_visits` smallint DEFAULT NULL,             -- outpatient + emergency + inpatient visits
  `diag_group` varchar(30) DEFAULT NULL,            -- primary diagnosis group
  `admission_type` varchar(30) DEFAULT NULL,        -- Emergency, Urgent, Elective, Other/Unknown

  PRIMARY KEY (`encounter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. Quick check: after loading the data this should return 69979
-- SELECT COUNT(*) FROM diabetes_encounters;
