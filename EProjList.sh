#!/usr/bin/env bash
set -euo pipefail

# ====== CONFIG (can be overridden) ======
ORG="${ORG:-kmbl-devops}"          # or pass via env: ORG=yourorg
API="${API:-7.1-preview.4}"

# Exclusions (exact, case-sensitive). You can override with:
#   EXCLUDE="Name1,Name2" ADO_PAT=xxxxx bash script.sh
IFS=',' read -r -a EXCLUDE <<< "${EXCLUDE:-Builder Tools,DevOps Tasks}"
# ======================================

: "${ADO_PAT:?Set ADO_PAT environment variable with an Azure DevOps PAT (Org scope, Project & Team: Read)}"

BASE="https://dev.azure.com/${ORG}/_apis/projects?api-version=${API}"

# Helper: return 0 if $1 is in EXCLUDE array (exact match)
is_excluded() {
  local name="$1"
  for ex in "${EXCLUDE[@]}"; do
    [[ -n "$ex" && "$name" == "$ex" ]] && return 0
  done
  return 1
}

# Quick auth/URL check (log to stderr so stdout stays JSON-only)
http_code=$(curl -sS -o /dev/null -w '%{http_code}' -u ":${ADO_PAT}" "$BASE")
if [[ "$http_code" != "200" ]]; then
  {
    echo "API call failed (HTTP $http_code)."
    echo "Check org URL ($ORG) and PAT scopes (Org: Project and Team Read)."
  } >&2
  # Return empty list to keep external data source happy
  printf '{"projects":[]}\n'
  exit 0
fi

# Collect project names (after exclusion)
projects=()
token=""
while :; do
  url="$BASE"
  [[ -n "$token" ]] && url="${BASE}&continuationToken=${token}"

  json=$(curl -sS -u ":${ADO_PAT}" "$url")

  # Extract names without jq:
  # 1) Flatten; 2) split objects; 3) grab value after "name"
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    if ! is_excluded "$name"; then
      projects+=("$name")
    fi
  done < <(
    echo "$json" \
      | tr -d '\n' \
      | sed 's/},{/}\n{/g' \
      | awk -F'"' '/"name":/ {for(i=1;i<=NF;i++) if($i=="name"){print $(i+2)}}'
  )

  token=$(printf '%s' "$json" | sed -n 's/.*"continuationToken":"\([^"]*\)".*/\1/p' || true)
  [[ -z "$token" ]] && break
done

# ---- JSON OUTPUT (stdout) ----
# No external deps; assumes project names don't contain quotes.
if ((${#projects[@]} == 0)); then
  printf '{"projects":[]}\n'
else
  # join with "," and wrap with ["..."]
  buf=""
  for p in "${projects[@]}"; do
    # basic escape for backslashes and double-quotes
    esc="${p//\\/\\\\}"
    esc="${esc//\"/\\\"}"
    if [[ -z "$buf" ]]; then
      buf="\"$esc\""
    else
      buf+=",\"$esc\""
    fi
  done
  printf '{\"projects\":[%s]}\n' "$buf"
fi
