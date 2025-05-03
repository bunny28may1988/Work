#!/usr/bin/env bash -x
<<  KOTAK
Author: KMBL335304
Tittle: DBTracker Log Tracker.
KOTAK
checkOccu=$(grep "SQL> CREATE" Sample.log | cut -d ' ' -f2- | wc -l)
grep "SQL> CREATE" Sample.log | cut -d ' ' -f2- > Ouste.txt
for i in $(seq 1 $checkOccu)
  do
    echo "########!!!!!!!!!!!!!!##################"
    pat=$(cat Ouste.txt | awk "NR==${i}{print}")
    cat Ouste.txt
    sed -n  -e "/${pat}/,/SQL>/{x;p;d;}" Sample.log| cut -d " " -f2-
  done
rm Ouste.txt  
SQL> CREATE OR REPLACE
SQL> CREATE OR REPLACE procedure UPD_USER_MASTER_121123_0100