#!/usr/bin/env bash

CONTAINER="xsm"

printf "\n ----------------\n > Cleaning up container \"%s\"\n" $CONTAINER
printf "\n > Stopping \"%s\", Removing \"%s\".\n" "$(docker stop $CONTAINER)" "$(docker rm $CONTAINER)"
docker stop $CONTAINER
docker rm $CONTAINER