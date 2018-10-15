#!/bin/bash

docker build --build-arg user=$(whoami) --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t dev-env .
