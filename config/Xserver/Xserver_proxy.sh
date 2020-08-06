#!/bin/bash
set -e

if [[ "$1" = "ip" ]]; then
    echo "$X_SERVER_HOST"
    exit 0
fi

_DISPLAY=$1
X_SOCK=/tmp/.X11-unix/X${_DISPLAY}

function clean(){
    sudo rm -f $X_SOCK
}
clean

trap clean SIGTERM SIGINT

sudo socat UNIX-LISTEN:$X_SOCK,mode=0777,fork TCP:$X_SERVER_HOST:600${_DISPLAY},ignoreeof

