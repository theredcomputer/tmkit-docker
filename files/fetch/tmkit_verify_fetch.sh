#!/bin/bash

set -e

WORKDIR=$PWD
CATKIN_WS_DIR="/root/catkin_ws/"

function view_model {
    aarxc --gui package://fetch_description/robots/fetch.urdf
}

function sussman_prepare {
    cd $WORKDIR
    if [ ! -d "$WORKDIR/fetch-blocks" ]; then
        mkdir fetch-blocks
        cp tmkit/tmkit/demo/baxter-sussman/*.robray \
            tmkit/tmkit/demo/baxter-sussman/q0.tmp \
            tmkit/tmkit/demo/domains/blocksworld/tm-blocks.* \
            fetch-blocks
    fi
    cd $WORKDIR/fetch-blocks
}

function sussman_view {
    sussman_prepare
    aarxc --gui package://fetch_description/robots/fetch.urdf sussman-0.robray
}

function sussman_plan {
    echo "Function not yet implemented for Fetch. Please try again later."
    exit
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
    echo "Function not yet implemented for Fetch. Please try again later."
    exit
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
    echo "tmkit_verify_fetch.sh OPTION"
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

source $CATKIN_WS_DIR/devel/setup.bash

$1
