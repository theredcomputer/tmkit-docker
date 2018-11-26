#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please supply a container name."
    exit 1
fi

# This line is not very secure, as anything can now use X. It is not known
# if a better solution is available.
xhost +

docker start $1 
