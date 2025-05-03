import requests
#url = "https://dev.azure.com/kmbl-devops/FinacleDataPatch/_releaseProgress?_a=release-environment-logs&releaseId=1552&environmentId=3109"
url = "https://vsrm.dev.azure.com/kmbl-devops/FinacleDataPatch/_apis/release/releases/1552/logs?api-version=7.1"


r = requests.get(url)
