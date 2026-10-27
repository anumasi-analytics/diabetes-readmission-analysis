import getpass
from urllib.parse import quote_plus
import pandas as pd
from sqlalchemy import create_engine, text

# ---------- Settings ----------
DB_USER = "diabetes_user"
DB_PASS = quote_plus(getpass.getpass("MySQL password for diabetes_user: "))
DB_HOST = "localhost"
DB_PORT = 3306
DB_NAME = "diabetes_db"
TABLE = "diabetes_encounters"
CSV_PATH = r"D:\Projects\diabetes_project\data\cleaned\diabetes_features.csv"

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# ---------- 1. Read the CSV ----------
# keep_default_na=False stops pandas from turning text like "None" or "NA" into empty values
df = pd.read_csv(CSV_PATH, keep_default_na=False, low_memory=False)
print("Rows read from CSV:", len(df), "| Columns:", df.shape[1])

# ---------- 2. Empty the table first (so the script is safe to re-run) ----------
with engine.begin() as conn:
    conn.execute(text(f"TRUNCATE TABLE {TABLE}"))

# ---------- 3. Load the data into MySQL ----------
df.to_sql(TABLE, engine, if_exists="append", index=False,
          chunksize=2000, method="multi")
print("Load finished")

# ---------- 4. Check the result ----------
with engine.connect() as conn:
    n = conn.execute(text(f"SELECT COUNT(*) FROM {TABLE}")).scalar()
    rate = conn.execute(
        text(f"SELECT ROUND(AVG(readmitted_30) * 100, 2) FROM {TABLE}")
    ).scalar()
print("Rows in MySQL:", n)
print("30-day readmission rate (%):", rate)