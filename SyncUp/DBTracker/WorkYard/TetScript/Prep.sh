echo $(RELEASE.ENVIRONMENTNAME)
echo $(RELEASE.RELEASEID)
echo $(RELEASE.RELEASENAME)
echo $(RELEASE.REQUESTEDFOREMAIL)
echo $(RELEASE.RELEASEDESCRIPTION) | awk -F '-' '{print $2}'
echo $(RELEASE.RELEASEDESCRIPTION) | awk -F '-' '{print $1}'
echo $(RELEASE.RELEASEDESCRIPTION)  | awk -F '-' '{print $5}'
echo $(RELEASE.RELEASEDESCRIPTION)  | awk -F '-' '{print $6}'
echo $(CRQ)
projectName=$(echo $(RELEASE.RELEASEDESCRIPTION) | awk -F '-' '{print $1}' | xargs )
releaseId=$(echo $(RELEASE.RELEASEDESCRIPTION) | awk -F '-' '{print $2}' | xargs )
echo ${projectName} 
echo ${releaseId} 
echo $(AdminPAT)


projectName=$(echo $(RELEASE.RELEASEDESCRIPTION) | awk -F '-' '{print $1}' | xargs )
releaseId=$(echo $(RELEASE.RELEASEDESCRIPTION) | awk -F '-' '{print $2}' | xargs )
logFile="ReleaseLogs_${releaseId}.zip"
attemptCount=$(echo $(RELEASE.RELEASEDESCRIPTION)  | awk -F '-' '{print $6}')
midDir=$(echo $(RELEASE.RELEASEDESCRIPTION)  | awk -F '-' '{print $5}')
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
mv ReleaseLogs/${midDir}/Attempt${attemptCount}/*/*/*  $(System.DefaultWorkingDirectory) 
cd $(System.DefaultWorkingDirectory)
pwd
ls -la