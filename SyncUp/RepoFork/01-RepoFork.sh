#!/bin/bash
projectName="DevOps Tasks"
projectName=${projectName// /}
echo -e "\033[1;31mScan Started on $(az repos policy list --output table | grep "Git repository settings" | awk '{print $7}' | wc -l) Repositories\033[0m"
repoIds=$(az repos policy list --output table | grep "Git repository settings" | awk '{print $7}')

for repoId in $repoIds; do
    repoName=$(az repos list --output table | grep $repoId | awk '{print $2}')
    policyDetails=$(az repos policy list --repository-id $repoId --output json)
    allowedForkTargets=$(echo "$policyDetails" | grep -o '"allowedForkTargets": \w*' | awk -F': ' '{print $2}')
    policyID=$(az repos policy list --output table | grep $repoId | grep 'Git' | awk '{print $1}')
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

        az repos policy update --config @repoPolicy-$repoName.json --id $policyID > ./PolicyUpdate/$projectName/repoPolicy-$repoName.json
        echo -e "\033[1;32mFORK Disabled on Repo: $repoName Successfully\033[0m"
    else
        echo "******************"
        echo -e "\033[1;36mFORK is Disabled on\n****************** \n RepoName: $repoName \n PolicyID: $policyID \n RepoID: $repoId\033[0m"
    fi
done