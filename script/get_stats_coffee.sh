#!/bin/sh

if [ "$1" != "" ]; then
    if [ "$1" != "user" -a "$1" != "machine" -o "$2" = "" ]; then
        echo Wrong arguments.
        echo Usage $0 \[\[user\|machine\] id\]
        exit
    fi    
fi    

perl -Mojo -E 'say g("localhost:3000/stats/coffee/'$1'/'$2'")->body'
