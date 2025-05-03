#############################################\n
PipelineReleaseID=3012

ReleasepipelineName="Finacle-Datapatch"

ReleaseDate="2024-10-01"

ProjectName="Finacle-Datapatch"

Summery="Some Static Content!!!"

ChangeRequest="[CHG0095653]"

RowsUpdated="Not Applicable"

rmvSqlStat=($(ls | grep "SQL*"))
echo "PipelineReleaseID,ReleasePipelineName,ReleaseDate,ProjectName,Summary,ChangeTicket,RowsUpdated,SQLStatement" > test-gen.csv
  for stat in "${rmvSqlStat[@]}"
  do 
    echo "The Text File is ${rmvSqlStat[@]}"        
    echo "The Text File is ${stat}"   
       if [ ${stat} == "SQL-update.txt" ]
       then
        sed -n '/SQL> update/p;' ${stat} >stat.txt
        var=$(wc -l < stat.txt | xargs)
        cut -d ";" -f2- SQL-update.txt | sed -n '/^[0-9]/p' >rowup.txt
        for i in $(seq 1 $var); do
                fileRead=$(cat stat.txt | head -n $i | tail -n 1)
                RowsUpdated=$(cat rowup.txt | head -n $i | tail -n 1)
                echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${ProjectName}","${Summery}","${ChangeRequest}","${RowsUpdated}","${fileRead}"" >>test-gen.csv
        done
          rm rowup.txt ;rm stat.txt       
        elif [ ${stat} == "SQL-UPDATE.txt" ]
       then
         echo "UPDATE!!!" 
       else
         fileRead=$(ex +%j +%p -scq! "${stat}" | tr -d '^M')    
         echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${ProjectName}","${Summery}","${ChangeRequest}","${RowsUpdated}","${fileRead}"" >>test-gen.csv
         echo "${fileRead}"
        fi 
   done                      
                
:||{     
   case "${stat}" in
        "SQL-update.txt")  
                        sed -n '/SQL> update/,/SQL>/{x;p;d;}' "${stat}" | while read line ; 
                        do       
                        sta=$(echo ${line} | sed -n '/SQL> update/p') 
                        RowsUpdated=$(echo ${line}| sed -n '/[0-9] /p')
                        #echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${ProjectName}","${Summery}","${ChangeRequest}","${RowsUpdated}","${sta}"" >>test-gen.csv 
                        echo -e "${sta}"
                        #echo -e "#####${rowU}"
                        done
                        ;;
        "SQL-UPDATE.txt")  
                        echo "UPDATE Pattern Match!!"
                        ;;
        "SQL-INSERT.txt")  
                        echo "INSERT Pattern Match!!"
                        ;;
        "SQL-DELETE.txt") 
                        echo "DELETE Pattern Match!!"
                        ;;
                       *) 
                        fileRead=$(ex +%j +%p -scq! "${stat}" | tr -d '^M')	
                        #echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${Application\/ProjectName}","${Summery}","${ChangeRequest}","${RowsUpdated}","${fileRead}"" >>test-gen.csv
                        echo "${fileRead}"
                        ;;
    esac      
}