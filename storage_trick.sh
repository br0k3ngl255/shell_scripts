#!/usr/bin/env bash
###################################################
#created by : br0k3ngl255
#   Purpose: trick to get the size of storage size
##################################################
CHECK=`du -hs /path/to/directory`
regex="([0-9]+)G"

if [[ $CHECK =~ $regex && ${BASH_REMATCH[1]} -lt 10 && ${BASH_REMATCH[1]} -gt 2 ]]; then
     # do whatever you want
     echo "size is ${BASH_REMATCH[1]}G"
fi
