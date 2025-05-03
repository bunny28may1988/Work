cache:

cut -d ";" -f2- SQL-update.txt | sed -n '/^[0-9]/p' | while read line ; do echo "####\n$line" ; done 

sed -n '/SQL> update/p;' SQL-update.txt | while read line ; do echo $line ; done 

sed -n '/SQL> update/,/SQL>/{x;p;d;}' SQL-update.txt | while read line ; do sta=$(echo ${line} | sed -n '/SQL> update/p'); rowU=$(echo ${line}| sed -n '/[0-9]/p'); echo -e "${sta}\n${rowU}"; done

sed -n '/SQL> update/,/SQL>/{x;p;d;}' "${stat}" | while read line ; 
                        do       
                        echo ${line} | sed -n '/SQL> update/p'
                        #sta=$(ex +%j +%p -scq! ${line} | tr -d '^M')
                        RowsUpdated=$(echo ${line}| sed -n '/[0-9] /p')
                        #echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${Application}","${Summery}","${ChangeRequest}","${RowsUpdated}","${sta}"" >>test-gen.csv 
                        echo -e "${sta}"
                        echo -e "${RowsUpdated}"
                        sleep 10
                        done



:||{  
castCont=($(ls | grep "SQL*.*"))
for castCont in "${castCont[@]}"
do 
  #prt=$(cat "${castCont}")
prt=$(fold -sw 20 <"${castCont}")
echo -e ""${PipelineReleaseID}","${ReleasepipelineName}","${ReleaseDate}","${Application}","${Summery}","${ChangeRequest}","${prt}"">>test-gen.csv
done
}
sed -n -e "/SQL> select/p" 5_Deploy.log | cut -d ' ' -f2- | while read in line;
do
echo "#####################>"
echo "${line}"
patt=$(echo "/${line}/,/SQL>/{x;p;d;}")  
sed -n -e "${patt}" 5_Deploy.log | cut -d ' ' -f2-
done

sed -n -e "/SQL> Select/p" 5_Deploy.log | cut -d ' ' -f2- | while read in line;
do
echo "#####################>"
echo "${line}"
patt=$(echo "/${line}/,/SQL>/{x;p;d;}" | tr -d '*')
echo "${patt}"
sed -n -e "${patt}" 5_Deploy.log | cut -d ' ' -f2-
done
