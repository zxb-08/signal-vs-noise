import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# Real data from Splunk lab
windows = ["09:02","09:00","08:58","08:57","08:56","21:21","21:20","21:19","21:18","21:17","21:15","21:12"]
fails =   [0,      2,      1,      1,      1,      1,      1,      2,      1,      1,      7,      2]
is_attack = [False]*10 + [True] + [False]

colors = ["#d62728" if a else "#2ca02c" for a in is_attack]

fig, ax = plt.subplots(figsize=(9,5))
bars = ax.bar(windows, fails, color=colors)
ax.axhline(y=3, color="black", linestyle="--", linewidth=1.5, label="Proposed threshold = 3")
ax.set_xlabel("5-/1-minute time window")
ax.set_ylabel("Failed login attempts")
ax.set_title("Failed SSH Login Attempts per Time Window\n(Green = benign activity, Red = Hydra attack)")
ax.legend()
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.savefig("chart1_failcounts.png", dpi=220)
plt.close()

# Chart 2: before/after false positive comparison at different thresholds
thresholds = [1, 2, 3, 5, 10]
false_positives = []
true_positives = []
benign_counts = [0,2,1,1,1,1,1,2,1,1,2]  # excludes the attack window
attack_counts = [7]

for t in thresholds:
    fp = sum(1 for c in benign_counts if c >= t)
    tp = sum(1 for c in attack_counts if c >= t)
    false_positives.append(fp)
    true_positives.append(tp)

fig, ax = plt.subplots(figsize=(8,5))
x = range(len(thresholds))
width = 0.35
ax.bar([i - width/2 for i in x], false_positives, width, label="False positives (benign flagged)", color="#d62728")
ax.bar([i + width/2 for i in x], true_positives, width, label="True positives (attack caught)", color="#2ca02c")
ax.set_xticks(list(x))
ax.set_xticklabels([f"≥{t}" for t in thresholds])
ax.set_xlabel("Detection rule threshold (failed logins per window)")
ax.set_ylabel("Count")
ax.set_title("Rule Accuracy vs. Threshold\n(11 benign windows, 1 attack window)")
ax.legend()
plt.tight_layout()
plt.savefig("chart2_threshold_tuning.png", dpi=220)
plt.close()

print("done")
