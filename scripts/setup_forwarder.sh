#!/bin/bash
# ============================================================
# Splunk Universal Forwarder setup — Kali Linux VM
# Signal vs Noise: Measuring Alert False-Positive Rates in Splunk
# ============================================================
# Run this on the monitored VM (attacker/victim host) AFTER
# installing Splunk Enterprise on your indexer/dashboard host.
# Replace <HOST_IP> and <PASSWORD> before running.

set -e

HOST_IP="<HOST_IP>"          # IP of the machine running Splunk Enterprise
FORWARDER_PKG="splunkforwarder-*-linux-amd64.deb"

echo "[*] Installing Splunk Universal Forwarder..."
sudo dpkg -i $FORWARDER_PKG

echo "[*] Starting forwarder and accepting license..."
sudo /opt/splunkforwarder/bin/splunk start --accept-license

echo "[*] Restoring traditional syslog (Kali uses journald by default)..."
sudo apt update
sudo apt install -y rsyslog
sudo systemctl enable --now rsyslog

echo "[*] Pointing forwarder at indexer host $HOST_IP:9997..."
sudo /opt/splunkforwarder/bin/splunk add forward-server "$HOST_IP:9997" -auth admin:<PASSWORD>

echo "[*] Adding monitor for SSH authentication log..."
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log -auth admin:<PASSWORD>

echo "[*] Restarting forwarder..."
sudo /opt/splunkforwarder/bin/splunk restart

echo "[*] Verifying forward-server connection..."
sudo /opt/splunkforwarder/bin/splunk list forward-server -auth admin:<PASSWORD>

echo "[+] Done. Check the Splunk web UI (http://<HOST_IP>:8000) and search:"
echo "    index=* host=$(hostname)"
