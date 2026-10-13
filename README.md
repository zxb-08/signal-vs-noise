# Signal vs Noise

**Measuring alert false-positive rates in a live Splunk SIEM deployment.**

![Splunk](https://img.shields.io/badge/Splunk-Enterprise-black) ![MITRE](https://img.shields.io/badge/MITRE-T1110-red) ![Kali](https://img.shields.io/badge/Kali-Linux-blue) ![Status](https://img.shields.io/badge/release-v1.0-green)

A hands-on lab on *alert fatigue*: SOC analysts get flooded with false positives until they ignore real alerts. This project builds a real detection pipeline, generates attack and benign traffic, and measures where a brute-force rule turns into noise.

📄 **Full report:** [`report/Signal_vs_Noise_Research_Assignment.pdf`](report/Signal_vs_Noise_Research_Assignment.pdf)

---

## TL;DR

- Built a **Splunk Enterprise + Universal Forwarder** pipeline ingesting live SSH logs from Kali Linux.
- Ran a real **Hydra brute-force attack** plus **11 benign login-failure windows** (mistyped passwords, abandoned attempts, typo'd usernames).
- A rule flagging **any** failed login was wrong **91%** of the time.
- Threshold **≥3 failures/minute** removed all false positives and still caught the attack.

| Threshold | False positives (of 11 benign windows) | Attack detected? |
|---|---|---|
| ≥ 1 | 10 (91%) | ✅ Yes |
| ≥ 2 | 3 (27%) | ✅ Yes |
| **≥ 3** | **0 (0%)** | ✅ **Yes** |
| ≥ 10 | 0 (0%) | ❌ **No (missed)** |

**Takeaway:** too low means noise, too high means missed attacks. ≥3 was the best balance in this dataset.

![Threshold tuning chart](report/chart2_threshold_tuning.png)

---

## Detection

```spl
index=* host=kali "Failed password"
| rex "from (?<src_ip>\d+\.\d+\.\d+\.\d+)"
| bin _time span=1m
| stats count by src_ip, _time
| where count >= 3
```

Counts failed SSH logins per source IP in 1-minute windows and alerts at 3 or more.

Full queries, including a failures-then-success correlation variant: [`detection/failed_login_detection.spl`](detection/failed_login_detection.spl). Portable rule: [`detection/brute_force_ssh.sigma.yml`](detection/brute_force_ssh.sigma.yml).

**MITRE ATT&CK:** T1110 Brute Force (T1110.001 Password Guessing)

---

## Lab architecture

```
┌──────────────────────────┐            ┌──────────────────────────┐
│  Kali Linux VM           │            │  Host machine            │
│  (attacker + victim)     │   :9997    │  Splunk Enterprise       │
│  Splunk Universal        │ ────────▶  │  (indexer + dashboard)   │
│  Forwarder → auth.log    │            │  http://localhost:8000   │
└──────────────────────────┘            └──────────────────────────┘
```

Attack and victim traffic both used loopback (`127.0.0.1`) on one VM.

---

## Method

1. **Attack:** Hydra against a low-privilege test account (`testvictim`) over SSH, with varied wordlist sizes.
2. **Benign:** manual login failures simulating human error.
3. **Detect:** SPL aggregates failures per source IP in 1-minute windows.
4. **Analyze:** same query tested at thresholds 1, 2, 3, 5, 10.

---

## Limitations

- Small sample: **11 benign windows**, so rates are indicative, not statistically conclusive.
- Single source IP (loopback): multi-source or distributed attacks are untested.
- Manually generated benign traffic, not real user behavior.
- Slow "low and slow" attacks would evade a per-minute window.

**Next steps:** more benign data, multi-source attacks, longer time windows, per-user aggregation.

---

## Reproduce

