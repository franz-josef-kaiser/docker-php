#!/usr/bin/env bash

CONTAINER="xsm-init"

printf "\n ----------------\n > Running Docker container \"%s\"\n" $CONTAINER
docker run \
  --name $CONTAINER \
  --detach \
  --volume "${PWD}/src":/usr/src/xmlsitemap \
  -it \
  xmlsitemap-fpm

printf "\n > Mapping \"%s\" directories to local/ Docker host.\n" $CONTAINER
docker cp $CONTAINER:/usr/local/etc "$(pwd)/conf"
printf "\n > Cleaning up: Stopping \"%s\", Removing \"%s\".\n" "$(docker stop $CONTAINER)" "$(docker rm $CONTAINER)"