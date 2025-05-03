patterns=("SQL-update.txt" "SQL-UPDATE.txt" "SQL-INSERT.txt" "SQL-DELETE.txt" "SQL-insert.txt" "SQL-delete.txt")
for  pattern in "${patterns[@]}"
do
   echo "Checking for the ${pattern}"	
   case ${pattern} in
        "SQL-update.txt")  
                        echo "update Pattern Match!!"
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
                        echo "Normal Pattern!!!"
                        ;;
    esac                                                                                                                                              
done

:||{
	if [ "${pattern}" == "/SQL> update/, /SQL>/{x;p;d;}" ]; then
   	echo "update Pattern Match!!"
   elif[ "${pattern}" == "/SQL> UPDATE/, /SQL>/{x;p;d;}" ]
   	echo "UPDATE Pattern Match!!"
   elif[ "${pattern}" == "/SQL> INSERT/, /SQL>/{x;p;d;}" ]
   	echo "INSERT Pattern Match!!"
   else
   	echo "Normal Pattern Match!!!"
   fi


   fileRead=$(ex +%j +%p -scq! "${stat}" | tr -d '^M')	
   echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${Application}","${Summery}","${ChangeRequest}","Not This Time","${fileRead}",">>test-gen.csv
}
