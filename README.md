# 30-Day Readmission Analysis Among Diabetic Patients

An end-to-end healthcare data analytics project using **Python, MySQL and Power BI** to find which patient and hospital-stay factors are associated with 30-day hospital readmission.

> **Data notice:** The dataset (Diabetes 130-US Hospitals) is confidential and is **NOT included** in this repository. No patient-level data, CSV files or the Power BI (.pbix) file are uploaded here.

## Project Goal

Hospital readmissions within 30 days are costly and often a sign that a patient's care could be improved. The goal of this project is to:

1. Clean and prepare diabetic patient encounter data.
2. Measure the overall 30-day readmission rate.
3. Identify which factors (prior visits, length of stay, age, medication change, diagnosis, admission type) are associated with higher readmission.
4. Combine these factors into a simple risk segmentation (High, Medium, Lower risk).
5. Present the findings in an interactive three-page Power BI dashboard.

**Note:** The results show associations, not causes.

## Tools Used

| Tool | Purpose |
|------|---------|
| Python 3.12 (PyCharm) | Data profiling, cleaning, feature engineering, EDA charts, loading data into MySQL |
| MySQL | Storing the cleaned table and running 9 SQL analysis queries |
| Power BI Desktop | Interactive 3-page dashboard (DAX measures, slicers, page navigation) |
| Git / GitHub | Version control and project sharing (code only, no data) |

## Folder Structure

```text
diabetes_project/
├── python/
│   ├── 01_profile.py        # Profile the raw data
│   ├── 02_clean.py          # Clean data (101,766 rows -> 69,979 rows)
│   ├── 03_features.py       # Feature engineering (55 columns)
│   ├── 04_eda.py            # 7 EDA charts
│   └── 05_load_mysql.py     # Load cleaned data into MySQL
├── sql/
│   └── 06_sql_analysis.sql  # 9 analysis queries
├── charts/                  # EDA charts produced by 04_eda.py
├── powerbi/
│   └── screenshots/         # Dashboard screenshots (3 pages)
├── data/                    # NOT included (confidential dataset)
├── README.md
└── .gitignore
```

> The `data/` folder and the Power BI file (`.pbix`) are not part of this repository.


## How to Reproduce


> The dataset is **not included**. You must obtain it yourself through your own authorized access and follow its terms of use.

**1. Set up Python (3.12)**

```bash
pip install pandas matplotlib sqlalchemy pymysql
```

**2. Add the data (not provided)**

Create a `data/` folder in the project root and place the Diabetes 130-US Hospitals file there, using the file name expected by `python/01_profile.py`.

**3. Run the Python scripts in order** (from the project root)

```bash
python python/01_profile.py
python python/02_clean.py
python python/03_features.py
python python/04_eda.py
```

**4. Prepare MySQL**

Create a database named `diabetes_db` and a project user named `diabetes_user` with access to it.

**5. Load the cleaned data into MySQL**

```bash
python python/05_load_mysql.py
```

The script asks for the MySQL password when it runs. The password is never stored in the code. This creates the table `diabetes_encounters` (69,979 rows).

**6. Run the SQL analysis**

Open `sql/06_sql_analysis.sql` in MySQL Workbench (or any MySQL client) and run the 9 queries.

**7. Power BI**

Connect Power BI Desktop to the `diabetes_encounters` table in MySQL. The dashboard file (`.pbix`) is not included; the screenshots in `powerbi/screenshots/` show the final result.

## Key Findings

Overall, **8.98%** of patients (6,283 of 69,979) ended in 30-day readmission.

| Factor | Lowest group | Highest group |
|--------|--------------|---------------|
| Prior visits | 7.94% (0 visits) | 18.00% (6+ visits) |
| Length of stay | 7.53% (1-3 days) | 11.79% (8+ days) |
| Age | 6.19% (0-29 years) | 10.62% (80+ years) |
| Primary diagnosis group | 7.30% (Respiratory) | 10.80% (Injury) |
| Admission type | 8.29% | 9.29% (weak driver) |

**Other observations**

- **Medication change:** 9.44% (change) vs 8.60% (no change).
- **A1C test:** 81.65% of patients had no A1C test, and this group also had the highest readmission rate (9.11%).

**Combined risk segmentation**

| Risk segment | Definition | Patients | Readmission rate |
|--------------|-----------|----------|------------------|
| High risk | 3+ prior visits and 8+ days stay | 683 | 17.42% |
| Medium risk | Only one of the two (3+ prior visits or 8+ days stay) | 13,109 | 12.13% |
| Lower risk | Neither | 56,187 | 8.14% |

The highest single combination was **6+ prior visits with an 8+ day stay: 25.19%**.

> These results show **associations, not causes**.


## Dashboard Screenshots

The Power BI dashboard has three pages with a page navigator, four synced slicers (age, gender, admission type, diagnosis) and a "Reset all filters" button. Only screenshots are included here; the `.pbix` file is not shared.

**1. Summary**

![Summary page](powerbi/screenshots/01_summary.png)

**2. Risk Drivers**

![Risk Drivers page](powerbi/screenshots/02_risk_drivers.png)

**3. Deep Dive**

![Deep Dive page](powerbi/screenshots/03_deep_dive.png)

## Limitations

- **Associations, not causes:** The analysis is descriptive. A higher readmission rate in a group does not mean that factor causes readmission.
- **No predictive model:** The High / Medium / Lower risk segments are simple rule-based groups built from prior visits and length of stay. They are not a validated prediction model and must not be used for clinical decisions.
- **Small high-risk group:** The High risk segment has only 683 patients (about 1% of the data), so its rate is based on a small group.
- **A1C data is mostly missing:** 81.65% of patients have no A1C test result, so conclusions about A1C are limited.
- **Weak drivers:** Medication change (9.44% vs 8.60%) and admission type (8.29% to 9.29%) show only small differences.
- **Data cleaning:** Cleaning reduced the data from 101,766 encounters to 69,979 patients. The main step was keeping only each patient's first encounter (29,341 repeat encounters removed), so the results describe first stays, not every stay.
- **Data not shared:** The dataset is confidential and not included, so the analysis can be repeated only by someone with their own authorized access to the data.