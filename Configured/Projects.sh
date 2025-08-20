#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
ADO_ORG_URL="https://dev.azure.com/kmbl-devops"   # <-- change this to your org
ADO_PAT="${ADO_PAT:?Need to set ADO_PAT}"        # read from env var (export ADO_PAT="...")

# === BASE64 encode the PAT ===
B64_PAT=$(printf ':%s' "$ADO_PAT" | base64)

# === API Call ===
response=$(curl -sS \
  -H "Authorization: Basic $B64_PAT" \
  -H "Content-Type: application/json" \
  "$ADO_ORG_URL/_apis/projects?api-version=7.0")

# === Extract project names using grep/sed ===
echo "Projects in $ADO_ORG_URL:"
echo "$response" | \
  grep -o '"name":"[^"]*' | \
  sed 's/"name":"//'