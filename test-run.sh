#!/bin/bash
set -e
docker-compose build
docker-compose up -d --force-recreate -t 1
docker-compose logs -f -t
