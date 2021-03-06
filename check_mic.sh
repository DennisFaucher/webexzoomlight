#!/bin/bash
#set -x
trigger=0

while true; do
# Check to see if Mac microphone in use. "IOAudioEngineState" = 1
     ioreg -l |grep '"IOAudioEngineState" = 1'
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
