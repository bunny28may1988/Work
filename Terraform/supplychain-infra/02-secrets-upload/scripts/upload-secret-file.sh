#!/bin/bash
set -x

check_secret_existence() {
  local secret_id="$1"
  if aws secretsmanager describe-secret --secret-id "$secret_id" >/dev/null 2>&1; then
    return 0  # Secret exists
  fi
  return 1  # Secret does not exist
}

get_secret_value_string() {
  local secret_id="$1"
  aws secretsmanager get-secret-value --secret-id "$secret_id" --query SecretString --output text
}

get_secret_value_binary() {
  local secret_id="$1"
  aws secretsmanager get-secret-value --secret-id "$secret_id" --query SecretBinary
}

update_binary_secret() {
  local secret_id="$1"
  local file_path="$2"

  aws secretsmanager put-secret-value \
    --secret-id "$secret_id" \
    --secret-binary "fileb://$file_path"
}

update_string_secret() {
  local secret_id="$1"
  local file_path="$2"

  aws secretsmanager put-secret-value \
    --secret-id "$secret_id" \
    --secret-string "file://$file_path"
}

secret_name=$1
secret_type=$2
file_path=$3

echo "Secret: $secret_name; Type: $secret_type; Path: $file_path"

existing_file_path=$(mktemp)
if check_secret_existence "$secret_name"; then
  if [[ "$secret_type" == "binary" ]]; then
    echo "Processing binary secret $secret_name"
    get_secret_value_binary "$secret_name" > "$existing_file_path"
    if ! cmp "$file_path" "$existing_file_path"; then
      echo "Updating existing secret for $secret_name"
      update_output=$(update_binary_secret "$secret_name" "$file_path" | jq .ARN)
      echo "Updated secret secret-id: \"$secret_name\" arn: $update_output"
    else
      echo "No change in secret-id: $secret_name"
    fi
  elif [[ "$secret_type" == "string" ]]; then
    echo "Processing string secret $secret_name"
    get_secret_value_string "$secret_name" > "$existing_file_path"
    if ! cmp "$file_path" "$existing_file_path"; then
      echo "Updating existing secret for $secret_name"
      update_output=$(update_string_secret "$secret_name" "$file_path" | jq .ARN)
      echo "Updated secret secret-id: \"$secret_name\" arn: $update_output"
    else
      echo "No change in secret-id: $secret_name"
    fi
  fi
else
  echo "Error: The secret with name '$secret_name' does not exist." >&2
  exit 1
fi
rm -f "$existing_file_path"