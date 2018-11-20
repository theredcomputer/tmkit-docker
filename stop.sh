#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please supply a container name."
    exit 1
fi

docker stop $1
