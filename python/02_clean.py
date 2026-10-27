import pandas as pd
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
raw_path = BASE / "data" / "raw" / "diabetic_data.csv"
out_path = BASE / "data" / "cleaned" / "diabetes_clean.csv"

# "?" means missing. "None" is real text (test not done), so keep it.
df = pd.read_csv(raw_path, na_values="?", keep_default_na=False, low_memory=False)

log = [f"Start: {len(df)} rows, {df.shape[1]} columns"]

# 1. Drop weight (96.9% missing)
df = df.drop(columns=["weight"])

# 2. Drop columns that have the same value in every row
const_cols = [c for c in df.columns if df[c].nunique(dropna=False) == 1]
df = df.drop(columns=const_cols)
log.append(f"Dropped constant columns: {const_cols}")

# 3. Remove invalid gender rows
df = df[df["gender"] != "Unknown/Invalid"]
log.append(f"After removing invalid gender: {len(df)} rows")

# 4. Remove patients who died or went to hospice (cannot be readmitted)
df = df[~df["discharge_disposition_id"].isin([11, 13, 14, 19, 20, 21])]
log.append(f"After removing expired/hospice: {len(df)} rows")

# 5. Remove rows with no primary diagnosis
df = df.dropna(subset=["diag_1"])
log.append(f"After removing missing diag_1: {len(df)} rows")

# 6. Fill remaining missing values with "Unknown"
for col in ["race", "payer_code", "medical_specialty", "diag_2", "diag_3"]:
    df[col] = df[col].fillna("Unknown")

# 7. "None" in test columns means the test was not done
for col in ["A1Cresult", "max_glu_serum"]:
    df[col] = df[col].replace("None", "Not Tested")

# 8. Keep only the first encounter for each patient
df = df.sort_values("encounter_id").drop_duplicates("patient_nbr", keep="first")
log.append(f"After keeping first encounter per patient: {len(df)} rows")

# Save
out_path.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(out_path, index=False)

# Summary (safe to share)
print("\n".join(log))
print("\nFINAL SHAPE:", df.shape)
print("\nMissing values left:", int(df.isna().sum().sum()))
print("\nreadmitted counts:")
print(df["readmitted"].value_counts().to_string())
rate = (df["readmitted"] == "<30").mean() * 100
print(f"\n30-day readmission rate: {rate:.2f}%")
print("\nA1Cresult counts:")
print(df["A1Cresult"].value_counts().to_string())
print("\nSaved to:", out_path)