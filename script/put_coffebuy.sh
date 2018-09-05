#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]; then
    echo Not enough arguments.
    echo Usage: $0 usr_id mch_id iso8601-timestump
    exit
fi    

perl -Mojo -E 'say u("localhost:3000/coffee/buy/'$1'/'$2'" => json => {timestamp => '"'$3'"'})->body'
