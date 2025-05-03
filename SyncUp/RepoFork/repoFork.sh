#!/bin/bash

# Fetch all repository IDs
repoIds=$(az repos policy list --output table | grep "Git" | awk '{print $7}')

# Loop through each repository ID and check the policy
for repoId in $repoIds; do
    #echo "Checking policies for repository ID: $repoId"
    
    # Fetch the repository name using the provided command
    repoName=$(az repos list --output table | grep $repoId | awk '{print $2}')
    
    # Fetch the policy details for the repository
    policyDetails=$(az repos policy list --repository-id $repoId --output json)
    
    # Check if "allowedForkTargets" is set to 1
    allowedForkTargets=$(echo "$policyDetails" | grep -o '"allowedForkTargets": [0-9]*' | awk -F': ' '{print $2}' | grep -w 1)
    policyID=$(az repos policy list --output table | grep $repoId | grep 'Git' | awk '{print $1}')
    if [ -n "$allowedForkTargets" ]; then
        # Print in yellow color if fork is enabled
        
        echo -e "\033[1;33mFORK is enabled on \n RepoName: $repoName \n PolicyID: $policyID \n RepoID: $repoId\033[1m"
        az repos policy update  --config @repoPolicy.json  --id $policyID
        echo "FORK Disabled on Repo: $repoName Successfully"
    else
        # Print in green color if fork is disabled
        #policyID=$(az repos policy list --output table | grep $repoId | awk '{print $1}')
        echo "******************"
        echo -e "\033[1;36mFORK is Disabled on\n****************** \n RepoName: $repoName \n PolicyID: $policyID \n RepoID: $repoId\033[0m"
        #echo "******************"
    fi
done