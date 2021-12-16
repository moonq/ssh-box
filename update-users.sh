#!/bin/bash
set -e
docker-compose exec ssh-ftp-server update_users.sh
