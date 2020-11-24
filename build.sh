#!/usr/bin/env bash
echo -en "\n ----------------\n > Building Docker container xmlsitemap-fpm\n ----------------\n"

docker build --tag xmlsitemap-fpm .

echo -en "\n ----------------\n"
docker images |grep xmlsitemap-fpm
echo -en "\n ----------------\n > DONE"