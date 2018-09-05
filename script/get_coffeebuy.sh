#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]; then
    echo Not enough arguments.
    echo Usage: $0 usr_id mch_id
    exit
fi    

perl -Mojo -E 'say g("localhost:3000/coffee/buy/'$1'/'$2'")->body'
