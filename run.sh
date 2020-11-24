#!/usr/bin/env bash

IMAGE="xmlsitemap-fpm"
CONTAINER="xsm"

docker run \
  --name $CONTAINER \
  --detach \
  --volume "${PWD}/src":/usr/src/xmlsitemap \
  --mount type=bind,source="${PWD}/conf/etc",target=/usr/local/etc,readonly \
  -it \
  $IMAGE

docker ps -a
docker logs $CONTAINER