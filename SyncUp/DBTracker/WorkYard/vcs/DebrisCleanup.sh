#!/usr/bin/env bash
ls | grep ".txt" >/dev/null
if [  $? != 0 ]; then
	echo "SQL Statemnt Files not Available"
else	
  rmvSqlStat=($(ls | grep ".txt"))  
  for stat in "${rmvSqlStat[@]}"
  do 
   rm "${stat}"
  done
fi