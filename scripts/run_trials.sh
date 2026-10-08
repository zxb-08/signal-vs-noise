#!/bin/bash
# ============================================================
# Attack + benign trial generator
# Signal vs Noise: Measuring Alert False-Positive Rates in Splunk
# ============================================================
# Reproduces the data-generation steps described in the report
# (Section 6, Methodology). Run on the Kali VM. Requires a
# `testvictim` low-privilege account to already exist.
#
#   sudo adduser testvictim   # set password to match passwords.txt

echo "=== ATTACK TRIAL: Hydra brute force (small wordlist) ==="
hydra -l testvictim -P passwords.txt ssh://127.0.0.1

echo ""
echo "=== ATTACK TRIAL: Hydra brute force (larger wordlist) ==="
hydra -l testvictim -P biggerpasswords.txt ssh://127.0.0.1

echo ""
echo "=== BENIGN TRIALS ==="
echo "Run these manually, one at a time, a few minutes apart,"
echo "so Splunk records each as a separate time window:"
echo ""
echo "  1. ssh testvictim@127.0.0.1   -> wrong password once, Ctrl+C"
echo "  2. ssh testvictim@127.0.0.1   -> wrong password twice, Ctrl+C"
echo "  3. ssh testvictim@127.0.0.1   -> wrong password several times, then succeed"
echo "  4. ssh nonexistentuser@127.0.0.1   -> any password (simulates a typo'd username)"
echo ""
echo "After running all trials, pull the dataset in Splunk with:"
echo "  detection/failed_login_detection.spl"
