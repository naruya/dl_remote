#!/bin/sh
export DISPLAY=:0
Xvfb :0 -screen 0 1400x900x24 &
icewm-session &
x11vnc -display :0 -passwd pass -forever -noxdamage &
