#!/bin/bash
#set -x
trigger=0

while true; do
     ps -ef | grep T33_64 | grep -v grep | grep -v standby > /dev/null
     result=$?
     if [ $result -eq 0 ] && [ $trigger -eq 0 ] 
     then
	python3 "/Users/faucherd/OneDrive - WWT/WWT/Innovation Games/2020/pywizlight/red.py"
	trigger=1
     elif [ $result -eq 1 ] && [ $trigger -eq 1 ]
     then
	python3 "/Users/faucherd/OneDrive - WWT/WWT/Innovation Games/2020/pywizlight/warmwhite.py"
	trigger=0
     fi
     sleep 5
done
