import pandas as pd
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
path = BASE / "data" / "raw" / "diabetic_data.csv"

df = pd.read_csv(path, low_memory=False)

print("ROWS, COLUMNS:", df.shape)
print("\n--- COLUMN INFO ---")
print(df.dtypes.to_string())

print("\n--- '?' (MISSING) COUNT PER COLUMN ---")
q = (df == "?").sum()
print(q[q > 0].to_string())

print("\n--- DUPLICATES ---")
print("Duplicate encounter_id:", df["encounter_id"].duplicated().sum())
print("Repeat patients (patient_nbr):", df["patient_nbr"].duplicated().sum())

print("\n--- VALUE COUNTS (key columns) ---")
for col in ["readmitted", "gender", "race", "age",
            "A1Cresult", "max_glu_serum", "change", "diabetesMed"]:
    print(f"\n{col}")
    print(df[col].value_counts(dropna=False).to_string())

print("\n--- NUMERIC SUMMARY ---")
print(df[["time_in_hospital", "num_lab_procedures", "num_procedures",
          "num_medications", "number_diagnoses"]].describe().round(2).to_string())