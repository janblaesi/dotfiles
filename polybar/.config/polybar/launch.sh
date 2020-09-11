#!/bin/bash

killall -q polybar
while pgrep -u $UID -x polxbar >/dev/null; do sleep 1; done

polybar mybar &

if [ "$1" = "qbit-multidisplay" ]; then
	polybar qbit-multidisplay-left &
	polybar qbit-multidisplay-right &
fi
