#!/bin/bash
pkill -9 -f Xvfb
pkill -9 -f x11vnc
pkill -9 -f websockify

Xvfb :99 -screen 0 1280x720x24 &
sleep 2
x11vnc -display :99 -nopw -forever -shared -bg -listen 0.0.0.0
sleep 2
python3 -m websockify --web /usr/share/novnc/ 8096 localhost:5900 &
sleep 2

cd /home/arika/cvat/tests
DISPLAY=:99 npx --yes corepack yarn@4.9.2 run cypress run --browser electron --headed --config viewportWidth=1280,viewportHeight=720
