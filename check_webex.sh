#!/bin/bash
#set -x
trigger=0
#rm /Users/faucherd/Dropbox/Lights/Red/red.txt
#rm /Users/faucherd/Dropbox/Lights/White/white.txt

while true; do
#     ps -ef | grep T33_64UMC_40.11.5.11 | grep -v grep | grep -v standby > /dev/null
     ps -ef | grep T33_64 | grep -v grep | grep -v standby > /dev/null
     result=$?
#     echo "Result: " $result
#     echo "Trigger: " $trigger
     if [ $result -eq 0 ] && [ $trigger -eq 0 ] 
     then
#        echo "WebEx in Progress…"
#	curl 'https://api.simplepush.io/send/tej9Ys/MeetingLight/Red'
	python3 "/Users/faucherd/OneDrive - WWT/WWT/Innovation Games/2020/pywizlight/red.py"
#	rm /Users/faucherd/Dropbox/Lights/White/white.txt
#	echo "red" > /Users/faucherd/Dropbox/Lights/Red/red.txt
	trigger=1
     elif [ $result -eq 1 ] && [ $trigger -eq 1 ]
     then
#	echo "WebEx Ended..."
	python3 "/Users/faucherd/OneDrive - WWT/WWT/Innovation Games/2020/pywizlight/warmwhite.py"
#	curl 'https://api.simplepush.io/send/tej9Ys/MeetingLight/White'
#	rm /Users/faucherd/Dropbox/Lights/Red/red.txt
#	echo "white" > /Users/faucherd/Dropbox/Lights/White/white.txt
	trigger=0
     fi
     sleep 5
done
