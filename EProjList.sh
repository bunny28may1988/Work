#!/usr/bin/env bash
set -euo pipefail

# ---- Read JSON from stdin (no jq) ----
read -r INPUT_JSON

# Extract fields "org", "pat", "exclude" from the single-line JSON
get_json_val() {
  # usage: get_json_val KEY
  # very simple extractor for flat JSON like {"org":"...","pat":"...","exclude":"a,b"}
  echo "$INPUT_JSON" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"
}

ORG=$(get_json_val org)
ADO_PAT=$(get_json_val pat)
EXCLUDE_RAW=$(get_json_val exclude || true)

# Defaults if not provided
: "${ORG:=kmbl-devops}"
: "${ADO_PAT:?Missing PAT in query JSON (key: \"pat\").}"
API="7.1-preview.4"

# Build exclude array from comma-separated string (optional)
EXCLUDE=()
if [[ -n "${EXCLUDE_RAW:-}" ]]; then
  IFS=',' read -r -a EXCLUDE <<< "$EXCLUDE_RAW"
fi

BASE="https://dev.azure.com/${ORG}/_apis/projects?api-version=${API}"

# Helper: return 0 if $1 is in EXCLUDE array (exact, case-sensitive)
is_excluded() {
  local name="$1"
  for ex in "${EXCLUDE[@]}"; do
    [[ -n "$ex" && "$name" == "$ex" ]] && return 0
  done
  return 1
}

# Quick auth/URL check (log errors to stderr so stdout stays JSON-only)
HTTP_CODE=$(curl -sS -o /dev/null -w '%{http_code}' -u ":${ADO_PAT}" "$BASE" || echo "000")
if [[ "$HTTP_CODE" != "200" ]]; then
  {
    echo "API call failed (HTTP $HTTP_CODE) for org: $ORG"
    echo "Check org URL and PAT scopes (Org-level: Project and Team - Read)."
  } >&2
  printf '{"projects":[]}\n'
  exit 0
fi

# Collect project names (after exclusion)
PROJECTS=()
TOKEN=""
while :; do
  URL="$BASE"
  [[ -n "$TOKEN" ]] && URL="${BASE}&continuationToken=${TOKEN}"

  JSON=$(curl -sS -u ":${ADO_PAT}" "$URL")

  # Extract names without jq:
  # 1) flatten; 2) split objects; 3) grab value after "name"
  while IFS= read -r NAME; do
    [[ -z "$NAME" ]] && continue
    if ! is_excluded "$NAME"; then
      PROJECTS+=("$NAME")
    fi
  done < <(
    echo "$JSON" \
      | tr -d '\n' \
      | sed 's/},{/}\n{/g' \
      | awk -F'"' '/"name":/ {for(i=1;i<=NF;i++) if($i=="name"){print $(i+2)}}'
  )

  TOKEN=$(printf '%s' "$JSON" | sed -n 's/.*"continuationToken":"\([^"]*\)".*/\1/p' || true)
  [[ -z "$TOKEN" ]] && break
done

# ---- JSON OUTPUT (stdout) ----
if ((${#PROJECTS[@]} == 0)); then
  printf '{"projects":[]}\n'
else
  # Build JSON array safely (escape \ and ")
  BUF=""
  for P in "${PROJECTS[@]}"; do
    ESC="${P//\\/\\\\}"; ESC="${ESC//\"/\\\"}"
    if [[ -z "$BUF" ]]; then BUF="\"$ESC\""; else BUF+=",\"$ESC\""; fi
  done
  printf '{"projects":[%s]}\n' "$BUF"
fi
