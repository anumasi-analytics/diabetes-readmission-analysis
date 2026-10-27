import pandas as pd
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
in_path = BASE / "data" / "cleaned" / "diabetes_clean.csv"
out_path = BASE / "data" / "cleaned" / "diabetes_features.csv"

df = pd.read_csv(in_path, low_memory=False)

# 1. Target flag: 1 = readmitted within 30 days
df["readmitted_30"] = (df["readmitted"] == "<30").astype(int)

# 2. Age group
age_map = {
    "[0-10)": "0-29", "[10-20)": "0-29", "[20-30)": "0-29",
    "[30-40)": "30-59", "[40-50)": "30-59", "[50-60)": "30-59",
    "[60-70)": "60-79", "[70-80)": "60-79",
    "[80-90)": "80+", "[90-100)": "80+",
}
df["age_group"] = df["age"].map(age_map)

# 3. Length of stay group
df["stay_group"] = pd.cut(
    df["time_in_hospital"],
    bins=[0, 3, 7, 100],
    labels=["Short (1-3 days)", "Medium (4-7 days)", "Long (8+ days)"],
)

# 4. Medication counts
med_cols = [
    "metformin", "repaglinide", "nateglinide", "chlorpropamide", "glimepiride",
    "acetohexamide", "glipizide", "glyburide", "tolbutamide", "pioglitazone",
    "rosiglitazone", "acarbose", "miglitol", "troglitazone", "tolazamide",
    "insulin", "glyburide-metformin", "glipizide-metformin",
    "glimepiride-pioglitazone", "metformin-rosiglitazone",
    "metformin-pioglitazone",
]
df["meds_active"] = (df[med_cols] != "No").sum(axis=1)
df["meds_changed"] = df[med_cols].isin(["Up", "Down"]).sum(axis=1)

# 5. Prior visits in the previous year
df["prior_visits"] = (
    df["number_outpatient"] + df["number_emergency"] + df["number_inpatient"]
)

# 6. Primary diagnosis group (ICD-9 codes)
def diag_group(code):
    code = str(code)
    if code.startswith(("V", "E")):
        return "Other"
    try:
        n = float(code)
    except ValueError:
        return "Other"
    if 250 <= n < 251:
        return "Diabetes"
    if 390 <= n <= 459 or n == 785:
        return "Circulatory"
    if 460 <= n <= 519 or n == 786:
        return "Respiratory"
    if 520 <= n <= 579 or n == 787:
        return "Digestive"
    if 800 <= n <= 999:
        return "Injury"
    if 710 <= n <= 739:
        return "Musculoskeletal"
    if 580 <= n <= 629 or n == 788:
        return "Genitourinary"
    if 140 <= n <= 239:
        return "Neoplasms"
    return "Other"

df["diag_group"] = df["diag_1"].apply(diag_group)

# 7. Admission type name
adm_map = {1: "Emergency", 2: "Urgent", 3: "Elective"}
df["admission_type"] = df["admission_type_id"].map(adm_map).fillna("Other/Unknown")

# Save
df.to_csv(out_path, index=False)

# Summary (safe to share)
print("FINAL SHAPE:", df.shape)
print("\nreadmitted_30 counts:")
print(df["readmitted_30"].value_counts().to_string())

for col in ["age_group", "stay_group", "diag_group", "admission_type"]:
    print(f"\n{col} counts:")
    print(df[col].value_counts().to_string())

print("\nmeds_active / meds_changed / prior_visits summary:")
print(df[["meds_active", "meds_changed", "prior_visits"]].describe().round(2).to_string())

print("\n30-day readmission rate by age_group (%):")
print((df.groupby("age_group")["readmitted_30"].mean() * 100).round(2).to_string())

print("\nSaved to:", out_path)