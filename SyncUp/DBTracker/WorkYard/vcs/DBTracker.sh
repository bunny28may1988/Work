#!/usr/bin/env bash
<<  KOTAK
Author: KMBL335304
Tittle: DBTracker Log Tracker.
KOTAK
[[ -f $(ls | grep "test-gen.csv") ]] && rm "test-gen.csv" || echo >/dev/null 
ls | grep "SQ*" >/dev/null
if [  $? != 0 ]; then
  echo >/dev/null #"SQL Statemnt Files not Available"
else  
  rmvSqlStat=($(ls | grep "SQ*"))  
  for stat in "${rmvSqlStat[@]}"
  do 
   rm "${stat}"
  done
fi
mv *Agent*.log $(ls | grep *Agent*.log| tr -d ' ')
varfile=$(ls|grep *Agent*.log)
[[ -e ${varfile} ]] && echo >/dev/null || exit 1
PipelineReleaseID=$(cat ${varfile} | grep RELEASE_RELEASEID | cut -d '[' -f3 | tr -d ']')
ReleasepipelineName=$(cat ${varfile} | grep RELEASE_DEFINITIONNAME | cut -d '[' -f3 | tr -d ']')
ReleaseDate=$(cat ${varfile}  | grep RELEASE_DEPLOYMENT_STARTTIME | cut -d '[' -f3 | tr -d ']' | awk -F ' ' '{print $1}')
ProjectName=${ReleasepipelineName}
Summery="Some Static Content!!!"
ChangeRequest=$(cat ${varfile} | grep -w  CRQ | cut -d ' ' -f3)
[ $(echo ${#ChangeRequest}) -le 3 ] &&  ChangeRequest="Not Specified" || echo >/dev/null
DBName=$(cat ${varfile} | grep -w  "DEFINE _CONNECT_IDENTIFIER" | cut -d '/' -f4 | cut -d '"' -f1)
SchemaUser=$(cat ${varfile} | grep -w  "DEFINE _USER" | awk -F '=' '{print $2}'| cut -d '"' -f2)
echo  -e """
#############################################\n
PipelineReleaseID=${PipelineReleaseID}\n
ReleasepipelineName=${ReleasepipelineName}\n
ReleaseDate=${ReleaseDate}\n
ProjectName=${ProjectName}\n
Summery=${Summery}\n
ChangeRequest=${ChangeRequest}\n
RowsUpdated="Not Applicable"
#############################################\n
"""
patterns=("/SQL> DEF/,/SQL>/{x;p;d;}" "/SQL> CREATE/,/SQL>/{x;p;d;}" "/SQL> \EXEC/,/SQL>/{x;p;d;}" "/SQL> exec/,/SQL>/{x;p;d;}" "/SQL> GRANT/,/SQL>/{x;p;d;}" "/SQL> update/,/SQL> commit/I{x;p;d;}" "/SQL> Insert/,/SQL>/{x;p;d;}")
fileName=$(ls | grep [0-9]_Dep*.log)
[[ -e $fileName ]] && echo >/dev/null || exit 1
for  pattern in "${patterns[@]}" 
do
	echo "Running for Pattern ${pattern}"
file=$(echo ${pattern} | awk -F '>' '{print $2}' | cut -d '/' -f1 | tr -d ' ')
sed -n  -e "${pattern}" "${fileName}"| awk -F " " 'NR==2 {print $1}' >"Time-${file}".txt
sed -n  -e "${pattern}" "${fileName}"| cut -d " " -f2- >"SQ-${file}".txt
done
find . -size 0 -delete
rmvSqlStat=($(ls | grep "SQ*"))
  for stat in "${rmvSqlStat[@]}"
  do 
   if [ ${stat} == "SQ-update.txt" ]
       then
        sed -n '/SQL> update/Ip;' ${stat} | tr -d ',' | tr -d '\t' >stat.txt
        var=$(wc -l < stat.txt | xargs)
        cut -d ";" -f2- ${stat}| sed -n '/^[0-9]/p'  | awk -F ' ' '{print $1}' >rowup.txt
        sed -n '/SQL> update/Ip;' "${fileName}" | awk -F " " '{print $1}' >PickTime.txt
        for i in $(seq 1 $var); do
                fileRead=$(cat stat.txt | head -n $i | tail -n 1)
                RowsUpdated=$(cat rowup.txt | head -n $i | tail -n 1 )
                TimeStamp=$(cat PickTime.txt | head -n $i | tail -n 1 )
                echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${ProjectName}","${Summery}","${ChangeRequest}","${RowsUpdated}","${fileRead}","${TimeStamp}"" > "${i}-Final-${stat}"
                ex +%j +%p -scq! "${i}-Final-${stat}" | tr -d '^M' >"${i}-Finally-${stat}"
                awk -F\" -vOFS=\" '{for (i=1; i <= NF; i+=2) gsub(",", ":::", $i); print}' "${i}-Finally-${stat}" > "DidIt-${i}-${stat}"
        done
          rm rowup.txt;rm stat.txt ; RowsUpdated="Not Applicable"    
        elif [ ${stat} == "SQ-Insert.txt" ]
       then
         sed -n '/SQL> Insert/Ip;' ${stat} | tr -d ',' | tr -d '\t' >stat.txt
         var=$(wc -l < stat.txt | xargs)
         cut -d ";" -f2- ${stat}| sed -n '/^[0-9]/p' | awk -F ' ' '{print $1}' >rowup.txt
         sed -n '/SQL> Insert/Ip;' "${fileName}" | awk -F " " '{print $1}' >PickTime.txt
         for i in $(seq 1 $var); do
                fileRead=$(cat stat.txt | head -n $i | tail -n 1)
                RowsUpdated=$(cat rowup.txt | head -n $i | tail -n 1 )
                TimeStamp=$(cat PickTime.txt | head -n $i | tail -n 1 )
                echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${ProjectName}","${Summery}","${ChangeRequest}","${RowsUpdated}","${fileRead}","${TimeStamp}"" > "${i}-Final-${stat}"
                ex +%j +%p -scq! "${i}-Final-${stat}" | tr -d '^M' >"${i}-Finally-${stat}"
                awk -F\" -vOFS=\" '{for (i=1; i <= NF; i+=2) gsub(",", ":::", $i); print}' "${i}-Finally-${stat}" > "DidIt-${i}-${stat}"
         done
          rm rowup.txt;rm stat.txt ; RowsUpdated="Not Applicable"     
       else
       	 PipelineReleaseID=${PipelineReleaseID}
         ReleasepipelineName=${ReleasepipelineName}
         ReleaseDate=${ReleaseDate}
         ProjectName=${ProjectName}
         Summery=${Summery}
         ChangeRequest=${ChangeRequest}
         RowsUpdated="Not Applicable"
         fileRead="\"$(ex +%j +%p -scq! "${stat}" | tr -d '^M' )\""
         #echo ${fileRead}
         a=$(echo ${stat} | awk -F '-' '{print $2}')
         tme=$(echo "Time-${a}")
         TimeStamp=$(cat ${tme})
         echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${ProjectName}","${Summery}","${ChangeRequest}","${RowsUpdated}","${fileRead}","${TimeStamp}"" >"Final-${stat}"
         ex +%j +%p -scq! "Final-${stat}" | tr -d '^M' >"Finally-${stat}"
         awk -F\" -vOFS=\" '{for (i=1; i <= NF; i+=2) gsub(",", ":::", $i); print}' "Finally-${stat}" > "DidIt-${stat}"   
       fi      
  done
finCut=($(ls | grep DidIt))
echo -e "PipelineReleaseID,ReleasePipelineName,ReleaseDate,ProjectName,Summary,ChangeTicket,RowsUpdated,SQLStatement,TimeStamp" >${ProjectName}.csv
for fin in "${finCut[@]}"
do
  Col1=$(awk -F ':::' '{print $1}' "${fin}")
  Col2=$(awk -F ':::' '{print $2}' "${fin}")
  Col3=$(awk -F ':::' '{print $3}' "${fin}")
  Col4=$(awk -F ':::' '{print $4}' "${fin}")
  Col5=$(awk -F ':::' '{print $5}' "${fin}")
  Col6=$(awk -F ':::' '{print $6}' "${fin}")
  Col7=$(awk -F ':::' '{print $7}' "${fin}")
  Col8=$(awk -F ':::' '{print $8}' "${fin}")
  Col9=$(awk -F ':::' '{print $9}' "${fin}")
  echo -e  "${Col1},${Col2},${Col3},${Col4},${Col5},${Col6},${Col7},${Col8},${Col9}" >>${ProjectName}.csv
done
ls | grep "SQ*" >/dev/null
if [  $? != 0 ]; then
	echo "SQL Statemnt Files not Available"
else	
  rmvSqlStat=($(ls | grep ".txt"))  
  for stat in "${rmvSqlStat[@]}"
  do 
   rm "${stat}"
  done
fi