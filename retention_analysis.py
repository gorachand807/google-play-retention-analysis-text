# retention_analysis.py
# Google Play Store Retention Analysis - Python part
import pandas as pd
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

df = pd.read_csv('../data/sample_events.csv')

# 1. Retention by variant
summary = df.groupby('variant').agg(
    n_users=('user_id','count'),
    d7_rate=('retained_d7','mean'),
    d1_rate=('retained_d1','mean')
).reset_index()
print(summary)

# 2. A/B Test - Two proportion z-test
from statsmodels.stats.proportion import proportions_ztest
count = df.groupby('variant')['retained_d7'].sum().values # [control, treatment] order may vary
nobs = df.groupby('variant')['retained_d7'].count().values
# Ensure order control, treatment
control = df[df.variant=='control']['retained_d7']
treatment = df[df.variant=='treatment']['retained_d7']
stat, pval = proportions_ztest([treatment.sum(), control.sum()], [len(treatment), len(control)])
print(f"Z={stat:.2f}, p={pval:.4f}")

# 3. Confidence Interval for lift
lift = treatment.mean() - control.mean()
print(f"Lift: {lift*100:.2f}pp - {treatment.mean()*100:.1f}% vs {control.mean()*100:.1f}%")

# 4. Plot
plt.figure()
summary.plot(kind='bar', x='variant', y='d7_rate')
plt.title('D7 Retention by Variant')
plt.ylabel('D7 Retention')
plt.savefig('d7_retention_chart.png')
print("Chart saved")
