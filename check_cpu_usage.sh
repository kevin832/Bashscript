#!/bin/sh
#set -vx
## This script is to check the average CPU usage by running sar command (package sysstat is required to be installed ). 
## If it's higher than the threshold 90%, it will send out email to the recipients.

emails="email1@domain1.com, email2@domain2.com"
threshold=90

tempfile=`mktemp`
sar 1 5 > $tempfile
cat $tempfile
CPU=$(grep "Average" $tempfile | sed 's/^.* //')
## If statement in bash isn’t as friendly towards floating point variables as it is for integer and string variables.
## Here variable CPU is a floating number, so we can't just use if [ $CPU -lt $threshold  ] to compare the floating variables. 
## First of all the -gt and -lt switches don’t work. Even the unary operators >,<, etc. don’t work. 
## The only way is to do a comparison between the floating point variables using bc and using the logical outout as a comparison string.
compare_result=`echo "$threshold > $CPU" | bc`
if [ $compare_result -gt 0 ]
then
  cat $tempfile | \
  mail -s "`hostname` high CPU usage! - `date +"%D %T"`" $emails
else
  echo Okay
fi

rm $tempfile

