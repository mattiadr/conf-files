#!/bin/bash

rm mirrorlist.bak
mv mirrorlist mirrorlist.bak

reflector --country Austria --country Belgium --country Bulgaria --country Croatia --country Czechia --country Denmark --country Finland --country France --country Germany --country Greece --country Hungary --country Ireland --country Italy --country Latvia --country Lithuania --country Luxembourg --country Netherlands --country Poland --country Portugal --country Romania --country Slovakia --country Slovenia --country Spain --country Sweden --country 'United Kingdom' --protocol http --protocol https --latest 200 --sort rate --number 50 > mirrorlist