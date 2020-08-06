#!/bin/bash
set -e
sudo socat UNIX-LISTEN:/tmp/.X11-unix/X0,mode=0777,fork TCP:$X_SERVER_HOST:6000

