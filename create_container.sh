#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please supply a container name."
    exit 1
fi

# This line is not very secure, as anything can now use X. It is not known
# if a better solution is available.
xhost +

# Without the "--privileged" flag, GUI performance suffers tremendously.
docker run -d --privileged --name $1 -it \
  --env "DISPLAY=unix:0.0" \
  --workdir="/root" \
  --volume="$PWD/files/:/code/:rw" \
  --volume="/etc/group:/etc/group:ro" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  ${2:-theredcomputer/tmkit_docker:latest}

