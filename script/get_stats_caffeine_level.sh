#!/bin/sh

if [ "$1" = "" ]; then
    echo Wrong arguments.
    echo Usage $0 user_id
    exit
fi    

perl -Mojo -E 'say g("localhost:3000/stats/level/user/'$1'")->body'
