# Automatic "On-Air" WebEx/Zoom Light


Disclaimer: There are much more elegant ways to achieve this same result with WebEx/Zoom REST APIs, but this method works for me. Learning new REST APIs is always a steep curve. I used REST for the Philips light, but simple bash commands for WebEx and Zoom.

## Why

Every year, my awesome employer holds a Hackathon/Innovation Games. I have enjoyed being a participant every year. This year, one of the entries was for a light that changed color when one is in a webinar. Everyone loved the idea. Eventually, that team will share their code, but I've been thinking about how/if I could pull this off for myself. It would be cool if the light outside my office door turned red when I was on a webinar and back to warm white when my webinar completed so that people in our household would have an easy indication.

## How

Parts List

* A Computer
* WebEx and/or Zoom Client Installed
* Philips Wiz WiFi Light Bulb
* Recognize WebEx









As I wrote in the Disclaimer, there is probably an elegant REST API method to recognizing when my computer is in a WebEx meeting. I spent a few minutes reading the Cisco REST API Guide and decided I really did not need to learn yet another REST API to make this work. I fell back to bash and ps. I ran a ps -e before joining and a ps -e after leaving a WebEx webinar. What I found on my Mac was that the difference between just having the WebEx client running and actually being in a WebEx meeting was two processes. Both processes have the unique string "/Users/ faucherd/ Library/ Application Support/ WebEx Folder/ T33_64UMC_40.11.5.11" If I could trigger on the entrance and exit of that string, I would be all set. I created this shell script, check_webex.sh to do just that:

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

## Recognize Zoom








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

## Change Light Color












Now, how to programmatically change the color of a Philips Wiz WiFi bulb? I initially sent a notification to my phone which Tasker picked up on and made changes in the Android Wiz app. Very kludgey. I then started looking for REST APIs for these Wiz bulbs. Luckily, I found this excellent GitHub repo based on some Wiz reverse-engineering. As is the case with most consumer-grade IOT devices, these Wiz bulbs are wide open and do not require any authentication to control them. All one needs is their IP address or MAC address. Throw some JSON at them over the network and Bob's your Uncle!

## Steps to Use the Repo
This GitHub's repo ReadMe is very clear as to the simple installation:

````[bash]
git clone --resursive https://github.com/sbidy/pywizlight.git 
pip install pywizlight
````

That's it 🙂
Sample Python Code












I used the code right in the repo ReadMe Example section. I changed the IP address to the IP address of my bulb and then commented everything out except the lines that I needed. My two python scripts look like this (with commented lines removed)

### red.py

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

### warmwhite.py

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

That's it. I run check_webex.sh and check_zoom.sh in the background with the & suffix and everything works like magic. My next step is to add these two shell scripts to Mac startup using launchd.

## Thank You

Thank you for reading this post. I hope you have found the post helpful. I welcome your feedback.
