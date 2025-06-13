#!/bin/bash
set -e

# === Configuration ===
S3_BUCKET="skilluputilities"
SCRIPT_KEY="Scripts/install-multi-agent.sh"
LOCAL_SCRIPT="/opt/scripts/install-multi-agent.sh"
LOG_FILE="/var/log/ado-agent-install.log"
S3_LOG_KEY="Logs/ado-agent-install-$(date +%Y%m%d%H%M%S).log"

# === Create working directory ===
mkdir -p /opt/scripts
cd /opt/scripts

# === Install AWS CLI if not already installed ===
if ! command -v aws &>/dev/null; then
  echo "Installing aws-cli..." | tee -a "$LOG_FILE"
  yum install -y aws-cli >> "$LOG_FILE" 2>&1
else
  echo "aws-cli already installed." | tee -a "$LOG_FILE"
fi

# === Install libicu if not already installed ===
if ! rpm -q libicu &>/dev/null; then
  echo "Installing libicu..." | tee -a "$LOG_FILE"
  yum install -y libicu >> "$LOG_FILE" 2>&1
else
  echo "libicu already installed." | tee -a "$LOG_FILE"
fi

# === Download install script from S3 ===
echo "Downloading agent install script from S3..." | tee -a "$LOG_FILE"
aws s3 cp "s3://$S3_BUCKET/$SCRIPT_KEY" "$LOCAL_SCRIPT" >> "$LOG_FILE" 2>&1

# === Run the install script ===
chmod +x "$LOCAL_SCRIPT"
"$LOCAL_SCRIPT" >> "$LOG_FILE" 2>&1

echo "✅ Bootstrap complete." | tee -a "$LOG_FILE"

# === Upload log file to S3 ===
aws s3 cp "$LOG_FILE" "s3://$S3_BUCKET/$S3_LOG_KEY" || echo "⚠️ Failed to upload log to S3"
