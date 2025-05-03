#!/usr/bin/env bash
[[ -f $(ls | grep "test-gen.csv") ]] && rm "test-gen.csv" || echo >/dev/null 
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