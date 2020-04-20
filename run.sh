#!/bin/bash
set -e

[[ -z $name ]] && name='devenv'
project_path=`realpath "$1"`
project=`basename $project_path`
user=`whoami`
docker run --user $user \
    --name $name \
    --publish-all \
    --mount type=bind,source=${project_path},target=/home/$user/${project} \
    -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -it dev-env:latest

