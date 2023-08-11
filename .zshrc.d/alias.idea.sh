#!/bin/bash
[[ -d "/Applications/IntelliJ IDEA CE.app/Contents/MacOS" ]] && alias idea='open -a "$(ls -dt /Applications/IntelliJ\ IDEA*|head -1)"'
