#!/bin/bash
echo  $(PAT) | az devops login --organization https://dev.azure.com/kmbl-devops/
projectName="DevOps Tasks"
az devops configure -d project="DevOps Tasks"
projectName=${projectName// /}
mkdir -p ./PolicyUpdate/$projectName
echo "Checking for Fork Enabled Repos ......."
repoIds=$(az repos list --output table | awk '{print $1}' | awk 'NR>2')
for repoId in $repoIds; do
    repoName=$(az repos list --output table | grep "$repoId" | awk '{print $2}')
    chk=$(az repos policy list --output table | grep "$repoId" | awk '{print $1}')
    if [ -z "$chk" ]; then
        echo -e "\e[31mManually Check for the Fork Settings for the RepoName: $repoName\e[0m"
        #az repos policy case-enforcement create --blocking true --enabled false --repository-id $repoId --output table
    fi
done