#!/bin/bash
set -x

check_env_variable() {
  local name="$1"

  if [ -z "${!name}" ]; then
    echo "Error: The environment variable '$name' is not set." >&2
    exit 1
  fi
}

check_env_variable "SECRETS_FILE"

curr_dir=$(dirname "$0")

secrets=$(yq e -o=j -I=0 '.secrets[]' "$SECRETS_FILE")

for secret in $secrets; do

  secret_name=$(echo "$secret" | yq eval '.name' -)
  secret_type=$(echo "$secret" | yq eval '.type // "string"' -)
  file_path=$(mktemp)
  echo "$secret" | yq eval '.value' - | base64 -d > "$file_path"

  "$curr_dir"/upload-secret-file.sh "$secret_name" "$secret_type" "$file_path"

  rm -f "$file_path"
done