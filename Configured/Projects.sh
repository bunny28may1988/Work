#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG ======
ORG="kmbl-devops"   # <- exactly as in the URL: https://dev.azure.com/kmbl-devops
API="7.1-preview.4"
# ====================

: "${ADO_PAT:?Set ADO_PAT environment variable with an Azure DevOps PAT (Org scope, Project & Team: Read)}"

BASE="https://dev.azure.com/${ORG}/_apis/projects?api-version=${API}"

echo "Projects in https://dev.azure.com/${ORG}:"

# Quick auth/URL check
http_code=$(curl -sS -o /dev/null -w '%{http_code}' -u ":${ADO_PAT}" "$BASE")
if [[ "$http_code" != "200" ]]; then
  echo "  API call failed (HTTP $http_code)."
  echo "  Common causes:"
  echo "   • Wrong org name/URL (must be exactly ${ORG})"
  echo "   • PAT missing/expired/wrong scopes (needs Org-level ‘Project and Team: Read’)"
  echo "   • Org requires AAD sign-in or you lack access"
  exit 1
fi

# Loop for pagination (continuationToken is returned when there are more pages)
token=""
while :; do
  url="$BASE"
  [[ -n "$token" ]] && url="${BASE}&continuationToken=${token}"

  # Get the page
  json=$(curl -sS -u ":${ADO_PAT}" "$url")

  # Print project names (jq-free parsing)
  # 1) flatten to single line; 2) break objects per line; 3) extract "name":"..."
  echo "$json" \
    | tr -d '\n' \
    | sed 's/},{/}\n{/g' \
    | awk -F'"' '/"name":/ {for(i=1;i<=NF;i++) if($i=="name"){print $(i+2)}}'

  # Grab continuationToken (if any) from the response
  token=$(printf '%s' "$json" | sed -n 's/.*"continuationToken":"\([^"]*\)".*/\1/p' || true)
  [[ -z "$token" ]] && break
done
