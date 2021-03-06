#!/bin/bash
#set -x
trigger=0

while true; do
# Check to see if Mac microphone in use. "IOAudioEngineState" = 1
     ioreg -l |grep '"IOAudioEngineState" = 1'
     result=$?
#     echo "Result: " $result
#     echo "Trigger: " $trigger
     if [ $result -eq 0 ] && [ $trigger -eq 0 ] 
     then
#        echo "Microphone in Use…"
#	curl 'https://api.simplepush.io/send/tej9Ys/MeetingLight/Red'
	python3 "/Users/faucherd/OneDrive - WWT/WWT/Innovation Games/2020/pywizlight/red.py"
	trigger=1
     elif [ $result -eq 1 ] && [ $trigger -eq 1 ]
     then
#	echo "Microhone no longer in use..."
	python3 "/Users/faucherd/OneDrive - WWT/WWT/Innovation Games/2020/pywizlight/warmwhite.py"
#	curl 'https://api.simplepush.io/send/tej9Ys/MeetingLight/White'
	trigger=0
     fi
     sleep 5
done
