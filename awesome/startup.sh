#!/bin/bash

# mouse 4 and mouse 5
xinput set-button-map 'AlpsPS/2 ALPS DualPoint Stick' 8 2 9

# disable horizontal scroll
xinput set-prop 'AlpsPS/2 ALPS DualPoint TouchPad' 'libinput Horizontal Scroll Enabled' 0