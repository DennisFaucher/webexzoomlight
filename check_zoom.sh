#!/bin/bash
#set -x
trigger=0
while true; do
     ps -ef | grep CptHost | grep -v grep > /dev/null
     result=$?
#     echo "Result: " $result
#     echo "Trigger: " $trigger
     if [ $result -eq 0 ] && [ $trigger -eq 0 ] 
     then
#        echo "Zoom in Progress…"
	python3 "/Users/faucherd/OneDrive - WWT/WWT/Innovation Games/2020/pywizlight/red.py"
#	curl 'https://api.simplepush.io/send/tej9Ys/MeetingLight/Red'
	trigger=1
     elif [ $result -eq 1 ] && [ $trigger -eq 1 ]
     then
#	echo "Zoom Ended..."
	python3 "/Users/faucherd/OneDrive - WWT/WWT/Innovation Games/2020/pywizlight/warmwhite.py"
#	curl 'https://api.simplepush.io/send/tej9Ys/MeetingLight/White'
	trigger=0
     fi
     sleep 5
done
