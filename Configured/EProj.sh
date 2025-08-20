#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
ORG="kmbl-devops"
API="7.1-preview.4"

# Projects to exclude (space-separated list)
EXCLUDE=("Builder Tools" "DevOps Tasks")
# ====================

: "${ADO_PAT:?Set ADO_PAT environment variable with an Azure DevOps PAT (Org scope, Project & Team: Read)}"

BASE="https://dev.azure.com/${ORG}/_apis/projects?api-version=${API}"

echo "Projects in https://dev.azure.com/${ORG} (excluding: ${EXCLUDE[*]}):"

token=""
while :; do
  url="$BASE"
  [[ -n "$token" ]] && url="${BASE}&continuationToken=${token}"

  json=$(curl -sS -u ":${ADO_PAT}" "$url")

  # Extract names
  names=$(echo "$json" \
    | tr -d '\n' \
    | sed 's/},{/}\n{/g' \
    | awk -F'"' '/"name":/ {for(i=1;i<=NF;i++) if($i=="name"){print $(i+2)}}')

  # Exclude any that match the list
  for n in $names; do
    skip=false
    for ex in "${EXCLUDE[@]}"; do
      if [[ "$n" == "$ex" ]]; then
        skip=true
        break
      fi
    done
    $skip || echo "$n"
  done

  token=$(printf '%s' "$json" | sed -n 's/.*"continuationToken":"\([^"]*\)".*/\1/p' || true)
  [[ -z "$token" ]] && break
done