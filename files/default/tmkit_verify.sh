#!/bin/bash

set -e

WORKDIR=$PWD
BAXTER_COMMON_DIR="/code/"

function view_model {
    aarxc --gui package://baxter_description/urdf/baxter.urdf
}

function sussman_prepare {
    cd $WORKDIR
    if [ ! -d "$WORKDIR/baxter-blocks" ]; then
        mkdir baxter-blocks
        cp /root/tmkit/tmkit/demo/baxter-sussman/*.robray \
            /root/tmkit/tmkit/demo/baxter-sussman/q0.tmp \
            /root/tmkit/tmkit/demo/domains/blocksworld/tm-blocks.* \
            baxter-blocks
    fi
    cd $WORKDIR/baxter-blocks
}

function sussman_view {
    sussman_prepare
    aarxc --gui package://baxter_description/urdf/baxter.urdf sussman-0.robray
}

function sussman_plan {
    sussman_prepare
    tmsmt package://baxter_description/urdf/baxter.urdf \
        sussman-0.robray \
        allowed-collision.robray \
        tm-blocks.pddl \
        tm-blocks.py \
        -q q0.tmp \
        -g sussman-1.robray  \
        -o baxter-sussman.tmp
}

function sussman_visualize {
    sussman_prepare
    tmsmt package://baxter_description/urdf/baxter.urdf \
        sussman-0.robray \
        allowed-collision.robray \
        baxter-sussman.tmp \
        --gui
}

function sussman_run {
    sussman_prepare
    sussman_plan
    sussman_visualize
}

function print_help_and_exit {
    echo "Usage:"
    echo "tmkit_verify.sh OPTION"
    echo 
    echo "  Where OPTION is one of the following choices:"
    echo "           view_model - tests aarxc and GUI performance"
    echo "         sussman_view - render the Sussman envirionment"
    echo "         sussman_plan - plan the Sussman plan using tmsmt"
    echo "    sussman_visualize - observe the computed plan"
    echo
    echo "          sussman_run - plan and visualize the Sussman problem"
    echo
    echo
    exit

}

if [ -z $1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$1" == "-help" ]; then
    print_help_and_exit
fi

if [ ! -d "$BAXTER_COMMON_DIR/baxter_common" ]; then
    cd $BAXTER_COMMON_DIR
    git clone https://github.com/RethinkRobotics/baxter_common
fi

export ROS_PACKAGE_PATH=$BAXTER_COMMON_DIR/baxter_common

$1
