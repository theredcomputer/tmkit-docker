#!/bin/sh

#set -e

# Situation: sbdl needs to use the "personality" syscall.
# Task: Docker's default security policy doesn't allow these syscalls through.
# Action: Load a special version of dockerd with the syscall just for installation
# Result: Building the image should be successful

# Only problem: this requires sudo access.

if [ ! -z $(pgrep dockerd) ]; then
    echo 'Instance of dockerd found running. Shutting it down...' 
    sudo service docker stop
    sleep 3

    # Let's make extra sure.
    if [ ! -z $(pgrep dockerd) ]; then
        sudo pkill dockerd
    fi

    echo 'Done.'
fi

echo 'Starting special, necessary version of dockerd...'
sudo dockerd --seccomp-profile $(pwd)/docker_seccomp_personality.json &

# Give dockerd some time to breathe.
sleep 10
echo "dockerd started at PID $DOCKERD_PID."
sleep 1

# Commence the build.
docker build .

# Shutdown the special dockerd and start the normal service.
echo 'Killing special version of dockerd...'
if [ -z $(sudo pkill dockerd) ]; then
    sleep 3
    echo 'Done.'
fi
echo 'Restarting normal dockerd service...'
if [ -z $(sudo service docker start) ]; then
    echo "Done."  
else
    echo "Docker service not properly restarted. Finagling..."
    sudo service docker restart
    sleep 3
    sudo service docker stop
    sleep 3
    sudo service docker start
    sleep 3
    if [ ! -z $(pgrep dockerd) ]; then
        echo 'Dockerd successfully finagled!'
    fi
fi

