import pandas as pd
import matplotlib
matplotlib.use("Agg")  # saves charts to files, no pop-up windows
import matplotlib.pyplot as plt
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
df = pd.read_csv(BASE / "data" / "cleaned" / "diabetes_features.csv", low_memory=False)

chart_dir = BASE / "charts"
chart_dir.mkdir(exist_ok=True)

overall = df["readmitted_30"].mean() * 100
print(f"Overall 30-day readmission rate: {overall:.2f}%")

df["prior_visits_group"] = pd.cut(
    df["prior_visits"], bins=[-1, 0, 2, 5, 100], labels=["0", "1-2", "3-5", "6+"]
)

factors = {
    "age_group": "Age group",
    "stay_group": "Length of stay",
    "prior_visits_group": "Prior visits (last year)",
    "diag_group": "Primary diagnosis",
    "A1Cresult": "A1C result",
    "change": "Medication change",
    "admission_type": "Admission type",
}
sort_by_rate = ["diag_group", "A1Cresult", "change", "admission_type"]

for col, title in factors.items():
    g = df.groupby(col, observed=True)["readmitted_30"].agg(patients="count", rate="mean")
    g["rate"] = (g["rate"] * 100).round(2)
    if col in sort_by_rate:
        g = g.sort_values("rate", ascending=False)

    print(f"\n{title}")
    print(g.to_string())

    fig, ax = plt.subplots(figsize=(8, 4.5))
    ax.bar(g.index.astype(str), g["rate"])
    ax.axhline(overall, linestyle="--", color="red", label=f"Overall {overall:.2f}%")
    ax.set_title(f"30-day readmission rate by {title}")
    ax.set_ylabel("Readmission rate (%)")
    ax.legend()
    plt.xticks(rotation=30, ha="right")
    plt.tight_layout()
    fig.savefig(chart_dir / f"readmission_by_{col}.png", dpi=150)
    plt.close(fig)

print("\nCharts saved to:", chart_dir)