#!/bin/sh

if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]; then
    echo Not enough arguments.
    echo Usage: $0 login email password
    exit
fi    

perl -Mojo -E 'say u("localhost:3000/user/request" => json => {login => '"'$1'"', email => '"'$2'"', password => '"'$3'"'})->body'
