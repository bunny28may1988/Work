#!/bin/bash
set -e

# === Ensure root privileges ===
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root or with sudo." >&2
    exit 1
fi

# === Must be run inside an agent directory ===
if [ ! -f "./svc.sh" ] || [ ! -f "./config.sh" ]; then
    echo "❌ This does not appear to be a valid Azure DevOps agent directory." >&2
    exit 1
fi

# === Extract service name from .service file ===
if [ ! -f ".service" ]; then
    echo "❌ .service file not found. Cannot identify the systemd service name." >&2
    exit 1
fi

SERVICE_NAME=$(cat .service | tr -d '[:space:]')

if [ -z "$SERVICE_NAME" ]; then
    echo "❌ Could not extract service name from .service file." >&2
    exit 1
fi

echo "🔍 Detected agent service: $SERVICE_NAME"
echo "📍 Agent directory: $PWD"

# === Uninstall agent ===
echo "🛑 Stopping agent service..."
./svc.sh stop || true

echo "🧼 Uninstalling agent service..."
./svc.sh uninstall || true

# === Confirm and delete ===
echo "🧹 Cleaning up agent files in $PWD..."
rm -rf "$PWD"

echo "✅ Agent $SERVICE_NAME successfully uninstalled and directory removed."