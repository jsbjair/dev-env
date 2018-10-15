#!/bin/bash

user="$1"
docker build --build-arg user=$user --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t dev-env .
