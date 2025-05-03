projectName=$(echo echo $RELEASE_RELEASEDESCRIPTION | awk -F '-' '{print $1}' | xargs )
releaseId=$(echo echo $RELEASE_RELEASEDESCRIPTION | awk -F '-' '{print $2}' | xargs )
echo ${projectName} 
echo ${releaseId} 
echo "####\n$SECRET_PAT\n####"

projectName=$(echo $RELEASE_RELEASEDESCRIPTION | awk -F '-' '{print $1}' | xargs )
releaseId=$(echo $RELEASE_RELEASEDESCRIPTION | awk -F '-' '{print $2}' | xargs )
logFile="ReleaseLogs_${releaseId}.zip"
attemptCount=$(echo $RELEASE_RELEASEDESCRIPTION  | awk -F '-' '{print $6}')
midDir=$(echo $echo $RELEASE_RELEASEDESCRIPTION  | awk -F '-' '{print $5}')
[[ "$projectName" = "${projectName%[[:space:]]*}" ]] && echo >/dev/null || projectName=$(echo ${projectName} | sed 's/ /%20/g') ; echo ${projectName}
wget -O ${logFile} --no-check-certificate --quiet \
   --method GET \
  --timeout=0 \
  --header 'Authorization: Basic OjdzYnMybXlsanllZDRwc2tnM212djZtcGd3aXNuZ3luZ3QyYmRsdXJ4Z2h2eHR6cWN2cGE='  \
    "https://vsrm.dev.azure.com/kmbl-devops/${projectName}/_apis/release/releases/${releaseId}/logs?api-version=7.1"
 echo "https://vsrm.dev.azure.com/kmbl-devops/${projectName}/_apis/release/releases/${releaseId}/logs?api-version=7.1"
 ls -la
 pwd
 unzip -d ReleaseLogs ${logFile}
 mv ReleaseLogs/*/Attempt${attemptCount}/*/*/*  $SYSTEM_DEFAULTWORKINGDIRECTORY 
 cd $SYSTEM_DEFAULTWORKINGDIRECTORY
 pwd
 ls -la