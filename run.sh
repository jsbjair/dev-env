#!/bin/bash

project_path="$1"
project=`basename $project_path`
user=`whoami`
docker run --rm --user $user --mount type=bind,source=${project_path},target=/home/$user/${project} -it dev-env:latest

