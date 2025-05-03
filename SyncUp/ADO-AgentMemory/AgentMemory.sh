#!/bin/sh
#set -x
# Purpose: Monitor Linux disk space and send an email alert to $ADMIN
ALERT=90 # alert level 
ADMIN="you@cyberciti-biz" # dev/sysadmin email ID
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read -r output;
do
  echo "$output"
  usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1 )
  partition=$(echo "$output" | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" #|
    #mail -s "Alert: Almost out of disk space $usep%" "$ADMIN"
  fi
done