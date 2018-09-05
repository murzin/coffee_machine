#!/bin/sh

if [ "$1" = "" -o "$2" = "" ]; then
    echo Not enough arguments.
    echo Usage: $0 machine_name mg_per_cup
    exit
fi    

perl -Mojo -E 'say p("localhost:3000/machine" => json => {name => '"'$1'"', mg => '"'$2'"'})->body'
