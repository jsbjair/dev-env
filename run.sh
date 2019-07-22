#!/bin/bash

[[ -z $name ]] && name='devenv'
project_path=`realpath "$1"`
project=`basename $project_path`
user=`whoami`
docker run --rm --user $user \
    --name $name \
    --mount type=bind,source=${project_path},target=/home/$user/${project} \
    -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
    -it dev-env:latest

