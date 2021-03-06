# Automatic "On-Air" WebEx/Zoom Light
![WebEx & Zoom Logos](https://github.com/DennisFaucher/webexzoomlight/blob/main/images/header.png)

Disclaimer: There are much more elegant ways to achieve this same result with WebEx/Zoom REST APIs, but this method works for me. Learning new REST APIs is always a steep curve. I used REST for the Philips light, but simple bash commands for WebEx and Zoom.

## Why

Every year, my awesome employer holds a Hackathon/Innovation Games. I have enjoyed being a participant every year. This year, one of the entries was for a light that changed color when one is in a webinar. Everyone loved the idea. Eventually, that team will share their code, but I've been thinking about how/if I could pull this off for myself. It would be cool if the light outside my office door turned red when I was on a webinar and back to warm white when my webinar completed so that people in our household would have an easy indication.

## How

Parts List

* A Computer
* WebEx and/or Zoom Client Installed
* Philips [Wiz](https://www.usa.lighting.philips.com/consumer/smart-wifi-led) WiFi Light Bulb

### Recognize Live Microphone (v2)
[Edit] In version 1 of this repo, I used scripts to see if WebEx or Zoom was running on my Mac. I then had a thought - "If I could recognize a live microphone, it wouldn't matter what web conferencing system I was using." So that is what I tried to figure out next.

After some research, I learned that the command "ioreg -l |grep '"IOAudioEngineState" = 1'" would return true if any of the microphones on your Mac are live. Here are all the microphones on my Mac and their states during a recent webinar. You wills ee that My LG Ultrawide monitor microphone is not in use, my Logitech C920 webcam microphone is not in use, my Rode microphone _is_ in use, 

````[bash]
    | |   |                 +-o AppleGFXHDAEngineOutputDP  <class AppleGFXHDAEngineOutputDP, id 0x100008f85, registered, matched, active, busy 0 (1 ms), retain 15>
    | |   |                   | {
    | |   |                   |   "IOAudioEngineFlavor" = 1
    | |   |                   |   "IOAudioEngineOutputSampleLatency" = 2
    | |   |                   |   "IOAudioDeviceTransportType" = 1685090932
    | |   |                   |   "IOAudioEngineDescription" = "LG ULTRAWIDE"
    | |   |                   |   "IOAudioEngineSampleOffset" = 392
    | |   |                   |   "AllowDisplaySleep" = 0
    | |   |                   |   "IOAudioEngineOutputChannelLayout" = (1,2)
    | |   |                   |   "IOAudioEngineClientDescription" = {"kind"=0}
    | |   |                   |   "NoAutoRoute" = No
    | |   |                   |   "SupportAudioAUUC" = 1
    | |   |                   |   "IOAudioEngineClockDomain" = 500077696
    | |   |                   |   "IOAudioEngineClockIsStable" = Yes
    | |   |                   |   "IOAudioEngineState" = 0
    | |   |   |   |     |   +-o AppleUSBAudioEngine  <class AppleUSBAudioEngine, id 0x1000006fc, registered, matched, active, busy 0 (1388 ms), retain 13>
    | |   |   |   |     |     | {
    | |   |   |   |     |     |   "IOAudioStreamSampleFormatByteOrder" = "Little Endian"
    | |   |   |   |     |     |   "USBADC" = 0
    | |   |   |   |     |     |   "IOAudioEngineInputSampleOffset" = 36
    | |   |   |   |     |     |   "idProduct" = 2093
    | |   |   |   |     |     |   "IOGeneralInterest" = "IOCommand is not serializable"
    | |   |   |   |     |     |   "IOAudioEngineState" = 0
    | |   |   |   |     |     |   "locationID" = 336658432
    | |   |   |   |     |     |   "IOAudioEngineInputSampleLatency" = 4080
    | |   |   |   |     |     |   "IOAudioEngineDescription" = "HD Pro Webcam C920"
    | |   |   |   |     |   +-o AppleUSBAudioEngine  <class AppleUSBAudioEngine, id 0x1000006fe, registered, matched, active, busy 0 (1386 ms), retain 15>
    | |   |   |   |     |   | | {
    | |   |   |   |     |   | |   "IOAudioStreamSampleFormatByteOrder" = "Little Endian"
    | |   |   |   |     |   | |   "IOAudioEngineNumActiveUserClients" = 1
    | |   |   |   |     |   | |   "USBADC" = 0
    | |   |   |   |     |   | |   "IOAudioEngineInputSampleOffset" = 151
    | |   |   |   |     |   | |   "idProduct" = 3
    | |   |   |   |     |   | |   "IOGeneralInterest" = "IOCommand is not serializable"
    | |   |   |   |     |   | |   "IOAudioEngineState" = 1
    | |   |   |   |     |   | |   "locationID" = 337707008
    | |   |   |   |     |   | |   "IOAudioEngineInputSampleLatency" = 45
    | |   |   |   |     |   | |   "IOAudioEngineDescription" = "RODE NT-USB"
````
I updated my red light/white light script to check to see if any microphones were in use rather than whether a webinar was open. The new script looks liek this:

````[bash]
#!/bin/bash
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

````

That's it. Much simpler. I created a Mac Automator app that runs this script on login.

### Recognize WebEx

![WebEx Logo](https://github.com/DennisFaucher/webexzoomlight/blob/main/images/WebEx%20Logo.png)

As I wrote in the Disclaimer, there is probably an elegant REST API method to recognizing when my computer is in a WebEx meeting. I spent a few minutes reading the Cisco REST API [Guide](https://developer.webex.com/docs/api/getting-started) and decided I really did not need to learn yet another REST API to make this work. I fell back to bash and ps. I ran a ps -e before joining and a ps -e after leaving a WebEx webinar. What I found on my Mac was that the difference between just having the WebEx client running and actually being in a WebEx meeting was two processes. Both processes have the unique string "/Users/ faucherd/ Library/ Application Support/ WebEx Folder/ T33_64UMC_40.11.5.11" If I could trigger on the entrance and exit of that string, I would be all set. I created this shell script, check_webex.sh to do just that:

````[bash]
#!/bin/bash
trigger=0

while true; do
     ps -ef | grep T33_64UMC_40.11.5.11 | grep -v grep | grep -v standby > /dev/null
     result=$?
     if [ $result -eq 0 ] && [ $trigger -eq 0 ] 
     then
#        echo "WebEx in Progress…"
	python3 "/Users/faucherd/pywizlight/red.py"
	trigger=1
     elif [ $result -eq 1 ] && [ $trigger -eq 1 ]
     then
#	echo "WebEx Ended..."
	python3 "/Users/faucherd/pywizlight/warmwhite.py"
	trigger=0
     fi
     sleep 5
done
````

I am sure this could be easily modified for Windows. You can see that I debugged my rusty if statements with echo statements until everything was working. The sleep statement can be made longer if you like. A 5 second sleep means that it will take a max of 9 seconds to change the light color.  I then added the calls to python scripts to change the light color. More on those python scripts below.

### Recognize Zoom

![Zoom Logo](https://github.com/DennisFaucher/webexzoomlight/blob/main/images/Zoom%20Logo.png)

Just like for WebEx, for Zoom I ran a ps -e before joining and a ps -e after leaving a Zoom webinar. What I found on my Mac was that the difference between having the Zoom client running and not running (I quit Zoom after every meeting) was one process. This process has the unique string "/Applications/ zoom.us.app/ Contents/ Frameworks/ cpthost.app/ Contents/ MacOS/ CptHost" If I could trigger on the entrance and exit of that string, I would be all set. I created this shell script, check_zoom.sh to do just that:

````[bash]
#!/bin/bash
trigger=0
while true; do
     ps -ef | grep CptHost | grep -v grep > /dev/null
     result=$?
     if [ $result -eq 0 ] && [ $trigger -eq 0 ] 
     then
#        echo "Zoom in Progress…"
	python3 "/Users/faucherd/pywizlight/red.py"
	trigger=1
     elif [ $result -eq 1 ] && [ $trigger -eq 1 ]
     then
#	echo "Zoom Ended..."
	python3 "/Users/faucherd/pywizlight/warmwhite.py"
	trigger=0
     fi
     sleep 5
done
````

### Change Light Color

![Wiz Light](https://github.com/DennisFaucher/webexzoomlight/blob/main/images/Wiz%20Light.png)

Now, how to programmatically change the color of a Philips Wiz WiFi bulb? I initially sent a notification to my phone which Tasker picked up on and made changes in the Android Wiz app. Very kludgey. I then started looking for REST APIs for these Wiz bulbs. Luckily, I found this excellent GitHub [repo](https://github.com/sbidy/pywizlight) based on some Wiz reverse-engineering. As is the case with most consumer-grade IOT devices, these Wiz bulbs are wide open and do not require any authentication to control them. All one needs is their IP address or MAC address. Throw some JSON at them over the network and Bob's your Uncle!

### Steps to Use the Repo
This GitHub's repo ReadMe is very clear as to the simple installation:

````[bash]
git clone --resursive https://github.com/sbidy/pywizlight.git 
pip install pywizlight
````

That's it 🙂

### Sample Python Code

![Python Logo](https://github.com/DennisFaucher/webexzoomlight/blob/main/images/python-logo-master.png)

I used the code right in the repo ReadMe Example section. I changed the IP address to the IP address of my bulb and then commented everything out except the lines that I needed. My two python scripts look like this (with commented lines removed)

#### red.py

````[python]
import asyncio

from pywizlight.bulb import wizlight, PilotBuilder, discovery

async def main():
    # Set up a standard light
    light = wizlight("192.168.86.37")

    # Set bulb brightness (with async timeout)
    timeout = 10
    await asyncio.wait_for(light.turn_on(PilotBuilder(brightness = 255)), timeout)

    # Set RGB values
    # red to 0 = 0%, green to 128 = 50%, blue to 255 = 100%
    await light.turn_on(PilotBuilder(rgb = (255, 0, 0)))

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
````

#### warmwhite.py

````[python]
import asyncio

from pywizlight.bulb import wizlight, PilotBuilder, discovery

async def main():

    # Set up a standard light
    light = wizlight("192.168.86.37")

    # Set bulb brightness (with async timeout)
    timeout = 10
    await asyncio.wait_for(light.turn_on(PilotBuilder(brightness = 255)), timeout)

    # Set bulb to warm white
    await light.turn_on(PilotBuilder(warm_white = 255))

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
````

That's it. I run check_webex.sh and check_zoom.sh in the background with the & suffix and everything works like magic. My next step is to add these two shell scripts to Mac startup using [launchd](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html).

## Thank You

Thank you for reading this post. I hope you have found the post helpful. I welcome your feedback.
