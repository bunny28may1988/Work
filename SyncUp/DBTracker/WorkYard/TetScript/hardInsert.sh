list=($(ls | grep "Final"))
echo -e "PipelineReleaseID,ReleasePipelineName,ReleaseDate,ProjectName,Summary,ChangeTicket,RowsUpdated,SQLStatement,TimeStamp" >test-gen.csv
:||{
for li in "${list[@]}"
do
   col1=$(awk 'NR==1 {print}' "${li}")
   col2=$(awk 'NR==2 {print}' "${li}")
   col3=$(awk 'NR==3 {print}' "${li}")
   col4=$(awk 'NR==4 {print}' "${li}")
   col5=$(awk 'NR==5 {print}' "${li}")
   col6=$(awk 'NR==6 {print}' "${li}")
   col7=$(awk 'NR==7 {print}' "${li}")
   col8=$(awk 'NR==8 {print}' "${li}")
   col9=$(awk 'NR==9 {print}' "${li}")
   echo ""${col1}","${col2}","${col3}","${col4}","${col5}","${col6}","${col7}","${col8}","${col9}"" >>test-gen.csv
done

   col1=$(awk 'NR==1 {print}' Final-SQ-CREATE.txt | tr -d  ' ')
   col2=$(awk 'NR==2 {print}' Final-SQ-CREATE.txt | tr -d  ' ')
   col3=$(awk 'NR==3 {print}' Final-SQ-CREATE.txt | tr -d  ' ')
   col4=$(awk 'NR==4 {print}' Final-SQ-CREATE.txt | tr -d  ' ')
   col5=$(awk 'NR==5 {print}' Final-SQ-CREATE.txt | tr -d  ' ')
   col6=$(awk 'NR==6 {print}' Final-SQ-CREATE.txt | tr -d  ' ')
   col7=$(awk 'NR==7 {print}' Final-SQ-CREATE.txt | tr -d  ' ')
   col8=$(awk 'NR==8 {print}' Final-SQ-CREATE.txt | tr -d  ' ')
   col9=$(awk 'NR==9 {print}' Final-SQ-CREATE.txt | tr -d  ' ')
   #echo   "${col1}\n${col2}\n${col3}\n${col4}\n${col5}\n${col6}\n${col7}\n${col8}\n${col9}\n"
 
   Col1=$(awk -F ':::' '{print $1}' testyy.txt)
   Col2=$(awk -F ':::' '{print $2}' testyy.txt)
   Col3=$(awk -F ':::' '{print $3}' testyy.txt)
   Col4=$(awk -F ':::' '{print $4}' testyy.txt)
   Col5=$(awk -F ':::' '{print $5}' testyy.txt)
   Col6=$(awk -F ':::' '{print $6}' testyy.txt)
   Col7=$(awk -F ':::' '{print $7}' testyy.txt)
   Col8=$(awk -F ':::' '{print $8}' testyy.txt)
   Col9=$(awk -F ':::' '{print $9}' testyy.txt)
   
   echo -e "PipelineReleaseID,ReleasePipelineName,ReleaseDate,ProjectName,Summary,ChangeTicket,RowsUpdated,SQLStatement,TimeStamp" >test-gen.csv
   echo -e "Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9" >>test-gen.csv
   echo -e "Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9" >>test-gen.csv
   echo -e "Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9" >>test-gen.csv
   echo -e "Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9" >>test-gen.csv
 }  
   echo -e "PipelineReleaseID,ReleasePipelineName,ReleaseDate,ProjectName,Summary,ChangeTicket,RowsUpdated,SQLStatement,TimeStamp" >test-gen.csv
   echo -e '''"Col1","Col2","Col3","Col4","Col5","Col6","Col7","Col8","Col9"''' >>test-gen.csv
   #echo -e  "${Col1},${Col2},${Col3},${Col4},${Col5},${Col6},${Col7},${Col8},${Col9}" >>test-gen.csv
