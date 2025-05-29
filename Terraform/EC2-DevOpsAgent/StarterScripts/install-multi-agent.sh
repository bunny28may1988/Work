#!/bin/bash
set -e

# === Ensure root privileges ===
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root or with sudo."
    exit 1
fi

# === Static Config ===
AZP_URL="https://dev.azure.com/3angelsinv"
AZP_TOKEN="2RuWl2KurloJLCh1ox5r0CicIsgz4VDEAocaybQXLFjcY2JhdhCwJQQJ99BDACAAAAANsnKMAAASAZDO3et3"
AZP_POOL="SelfHosted-DockerAgent"
S3_BUCKET="eks-personal"
AGENT_TARBALL="utility/vsts-agent-linux-x64-4.255.0.tar.gz"
USER="app_user"
PASSWORD="Kotak@123"

# === Find next available agent index ===
BASE_DIR="/opt"
PREFIX="ADO-Agent"
INDEX=1

while [ -d "$BASE_DIR/${PREFIX}_$INDEX" ]; do
    INDEX=$((INDEX + 1))
done

AGENT_DIR="$BASE_DIR/${PREFIX}_$INDEX"
AGENT_NAME="${PREFIX}_${INDEX}-$(hostname)"
SERVICE_NAME="$AGENT_NAME"

echo "🆕 Creating new agent: $AGENT_NAME at $AGENT_DIR"

# === Ensure user exists ===
if ! id "$USER" &>/dev/null; then
    echo "👤 Creating user $USER..."
    useradd -m -s /bin/bash "$USER"
    echo "$USER:$PASSWORD" | chpasswd
    usermod -aG wheel "$USER"
else
    echo "ℹ️  User $USER already exists."
fi

mkdir -p "$AGENT_DIR"
chown -R "$USER:$USER" "$AGENT_DIR"
cd "$AGENT_DIR"

echo "⬇️  Downloading agent tarball..."
aws s3 cp "s3://$S3_BUCKET/$AGENT_TARBALL" ./agent.tar.gz

echo "📦 Extracting agent..."
tar -xzf agent.tar.gz
chown -R "$USER:$USER" "$AGENT_DIR"

echo "⚙️  Configuring agent with name $AGENT_NAME"
sudo -u "$USER" ./config.sh --unattended \
  --url "$AZP_URL" \
  --auth pat \
  --token "$AZP_TOKEN" \
  --pool "$AZP_POOL" \
  --agent "$AGENT_NAME" \
  --acceptTeeEula \
  --runAsService

echo "🚀 Installing and starting service: $SERVICE_NAME"
sudo ./svc.sh install
sudo ./svc.sh start

echo "✅ Agent $AGENT_NAME installed and running successfully!"