#!/usr/bin/env bash

set -e

docker-compose build --no-cache --force-rm --pull
docker-compose up -d
