#!/usr/bin/env bash
 <<  KOTAK
Author: KMBL335304
Tittle: DBTracker Log Tracker.
KOTAK
#echo "PipelineReleaseID,ReleasePipelineName,ReleaseDate,Application/Project-Name,Summary,ChangeTicket,DBName,SchemaUser,EventType,SQLStatement,RowCount " > test-gen.csv
#dte="14/10/2024"
varfile=$(ls | grep *Agent*.log)
echo ${varfile}
[[ -e ${varfile} ]] && echo >/dev/null || exit 1
PipelineReleaseID=$(cat ${varfile} | grep RELEASE_RELEASEID | cut -d '[' -f3 | tr -d ']')
ReleasepipelineName=$(cat ${varfile} | grep RELEASE_DEFINITIONNAME | cut -d '[' -f3 | tr -d ']')
ReleaseDate=$(cat ${varfile}  | grep RELEASE_DEPLOYMENT_STARTTIME | cut -d '[' -f3 | tr -d ']' | awk -F ' ' '{print $1}')
Application=${ReleasepipelineName}
Summery="Some Static Content!!!"
ChangeRequest=$(cat ${varfile} | grep -w  CRQ | cut -d ' ' -f3)
#(cat ${varfile} | grep -w  CRQ | awk -F '[' '{print $2}' | cut -d ' ' -f1 | tr -d ']' )
[ $(echo ${#ChangeRequest}) -le 3 ] &&  ChangeRequest="Not Specified" || echo >/dev/null
DBName=$(cat ${varfile} | grep -w  "DEFINE _CONNECT_IDENTIFIER" | cut -d '/' -f4 | cut -d '"' -f1)
SchemaUser=$(cat ${varfile} | grep -w  "DEFINE _USER" | awk -F '=' '{print $2}'| cut -d '"' -f2)
echo  -e """
#############################################\n
PipelineReleaseID=${PipelineReleaseID}\n
ReleasepipelineName=${ReleasepipelineName}\n
ReleaseDate=${ReleaseDate}\n
Application/ProjectName="${Application}"\n
Summery=${Summery}\n
ChangeRequest=${ChangeRequest}\n
#############################################\n
""" > variable.txt