#!/bin/bash

export PASS
echo "${PASS}"
if [ -z "${PASS}" ]; then
    echo "ERROR: PAT environment variable is not set. Exiting."
    exit 1
fi

echo "${PASS}" | az devops login --organization https://dev.azure.com/kmbl-devops/ || {
    echo "ERROR: Failed to authenticate using the supplied token."
    exit 1
}
echo "${PASS}" | az devops login --organization https://dev.azure.com/kmbl-devops/

projects=("CentralizedECR" "Sandbox" "APIManagement" "Builder Tools")
for proj in "${projects[@]}"; do
    echo "Processing project: $proj"
orga="https://dev.azure.com/kmbl-devops/"
az devops configure -d project="$proj"
projectName=${proj// /}
mkdir -p ./PolicyUpdate/$projectName
echo "Checking for Fork Enabled Repos ......."
repoIds=$(az repos list --org="$orga" --project="$proj" --output table | awk '{print $1}' | awk 'NR>2')
for repoId in $repoIds; do
    repoName=$(az repos list --org="$orga" --project="$proj" --output table | grep "$repoId" | awk '{print $2}')
    chk=$(az repos policy list --org="$orga" --project="$proj" --output table | grep "$repoId" | awk '{print $1}')
    if [ -z "$chk" ]; then
        echo -e "\e[33m Fork Enabled for the RepoName: $repoName\e[0m"
        az repos policy case-enforcement create --org="$orga" --project="$proj" --blocking true --enabled false --repository-id $repoId --output table
    fi
done
#########
echo -e "\033[1;31mScan Started on $(az repos policy list --org="$orga" --project="$proj" --output table | grep "Git repository settings" | awk '{print $7}' | wc -l) Repositories\033[0m"
repoIds=$(az repos policy list --org="$orga" --project="$proj" --output table | grep "Git repository settings" | awk '{print $7}')

for repoId in $repoIds; do
    repoName=$(az repos list --org="$orga" --project="$proj" --output table | grep $repoId | awk '{print $2}')
    policyDetails=$(az repos policy list --org="$orga" --project="$proj" --repository-id $repoId --output json)
    allowedForkTargets=$(echo "$policyDetails" | grep -o '"allowedForkTargets": \w*' | awk -F': ' '{print $2}')
    policyID=$(az repos policy list --org="$orga" --project="$proj" --output table | grep $repoId | grep 'Git' | awk '{print $1}')
    if [[ "$allowedForkTargets" == "null" || ( "$allowedForkTargets" =~ ^[1-9][0-9]*$ ) ]]; then
        echo -e "\033[1;33mFORK is enabled on \n RepoName: $repoName \n PolicyID: $policyID \n RepoID: $repoId\033[1m"
        cat <<EOF > @repoPolicy-$repoName.json
{
  "isEnabled": true,
  "isBlocking": true,
  "type": {
    "id": "7ed39669-655c-494e-b4a0-a08b4da0fcce"
  },
  "settings": {
    "allowedForkTargets": 0,
    "scope": [
      {
        "repositoryId": "$repoId"
      }
    ]
  }
}
EOF

        az repos policy update --org="$orga" --project="$proj" --config @repoPolicy-$repoName.json --id $policyID > ./PolicyUpdate/$projectName/repoPolicy-$repoName.json
        echo -e "\033[1;32mFORK Disabled on Repo: $repoName Successfully\033[0m"
    else
        echo "******************"
        echo -e "\033[1;36mFORK is Disabled on\n****************** \n RepoName: $repoName \n PolicyID: $policyID \n RepoID: $repoId\033[0m"
    fi
done
done
az logout --verbose