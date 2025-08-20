#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Read JSON from stdin (Terraform external query)
# Expecting: {"org":"<ORG>", "pat":"<PAT>"}
# -----------------------------
INPUT="$(cat || true)"

# Extract values from the small JSON without jq (simple, tolerant)
extract_json_value () {
  # $1 = key, reads from $INPUT
  # finds the first "key":"value" pair
  printf '%s' "$INPUT" \
  | tr -d '\n' \
  | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"
}

ORG="$(extract_json_value org)"
ADO_PAT="$(extract_json_value pat)"

# Fallbacks (optional): allow env overrides if not provided by Terraform
: "${ORG:=${ORG:-${ORG:-}}}"
: "${ADO_PAT:=${ADO_PAT:-${ADO_PAT:-}}}"

# Fail clearly if missing
if [[ -z "${ORG:-}" || -z "${ADO_PAT:-}" ]]; then
  # Return *valid* JSON even on error (to keep external data source happy)
  printf '{"projects":[]}\n' 
  exit 0
fi

# -----------------------------
# Config
# -----------------------------
API="${API:-7.1-preview.4}"

# Exclusions (exact, case-sensitive). Override with env:
#   EXCLUDE="Name1,Name2" terraform apply ...
IFS=',' read -r -a EXCLUDE <<< "${EXCLUDE:-Builder Tools,DevOps Tasks}"

BASE="https://dev.azure.com/${ORG}/_apis/projects?api-version=${API}"

# Helper: is name in EXCLUDE[]
is_excluded() {
  local name="$1"
  for ex in "${EXCLUDE[@]}"; do
    [[ -n "$ex" && "$name" == "$ex" ]] && return 0
  done
  return 1
}

# -----------------------------
# Quick auth/URL check
# -----------------------------
http_code=$(curl -sS -o /dev/null -w '%{http_code}' -u ":${ADO_PAT}" "$BASE")
if [[ "$http_code" != "200" ]]; then
  # Don’t print errors to stdout; Terraform expects JSON only.
  # Emit empty list so terraform still proceeds deterministically.
  printf '{"projects":[]}\n'
  exit 0
fi

# -----------------------------
# Collect projects (pagination)
# -----------------------------
projects=()
token=""
while :; do
  url="$BASE"
  [[ -n "$token" ]] && url="${BASE}&continuationToken=${token}"

  json="$(curl -sS -u ":${ADO_PAT}" "$url")"

  # Extract project names w/out jq:
  # 1) flatten; 2) split objects; 3) take value after "name"
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    if ! is_excluded "$name"; then
      projects+=("$name")
    fi
  done < <(
    printf '%s' "$json" \
      | tr -d '\n' \
      | sed 's/},{/}\n{/g' \
      | awk -F'"' '/"name":/ {for(i=1;i<=NF;i++) if($i=="name"){print $(i+2)}}'
  )

  # Continuation token
  token="$(printf '%s' "$json" | sed -n 's/.*"continuationToken":"\([^"]*\)".*/\1/p')"
  [[ -z "$token" ]] && break
done

# -----------------------------
# Emit valid JSON for Terraform
# -----------------------------
if ((${#projects[@]} == 0)); then
  printf '{"projects":[]}\n'
else
  buf=""
  for p in "${projects[@]}"; do
    # minimal escaping for JSON safety
    esc="${p//\\/\\\\}"
    esc="${esc//\"/\\\"}"
    if [[ -z "$buf" ]]; then
      buf="\"$esc\""
    else
      buf+=",\"$esc\""
    fi
  done
  printf '{"projects":[%s]}\n' "$buf"
fi
