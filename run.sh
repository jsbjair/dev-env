#!/bin/bash

project_path=`realpath "$1"`
project=`basename $project_path`
user=`whoami`
docker run --name fsdev-chrome --rm --privileged -p22 --user $user --mount type=bind,source=${project_path},target=/home/$user/${project} -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -it fsdev:1.0.1

