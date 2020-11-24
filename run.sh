#!/usr/bin/env bash
docker run --rm \
  --volume "${PWD}/src":/usr/src/xmlsitemap \
  -it xmlsitemap
