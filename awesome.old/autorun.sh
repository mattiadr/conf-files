#!/bin/bash

# USAGE: run application [args]
function run() {
	if ! pgrep $1 ;
	then
		$@&
	fi
}

run telegram-desktop -startintray