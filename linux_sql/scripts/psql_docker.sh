#!/bin/bash

# Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Start Docker if it's not running
sudo systemctl status docker >/dev/null 2>&1 || sudo systemctl start docker

# Check if container exists
docker container inspect jrvs-psql >/dev/null 2>&1
container_status=$?

case "$cmd" in
  create)
    # Container already exists
    if [ $container_status -eq 0 ]; then
      echo "Error: container already exists"
      exit 1
    fi

    # Check number of arguments
    if [ $# -ne 3 ]; then
      echo "Error: create requires USERNAME and PASSWORD"
      echo "Usage: ./psql_docker.sh create db_username db_password"
      exit 1
    fi

    echo "Creating volume..."
    docker volume create pgdata

    echo "Creating container..."
    docker run --name jrvs-psql \
      -e POSTGRES_USER="$db_username" \
      -e POSTGRES_PASSWORD="$db_password" \
      -d \
      -v pgdata:/var/lib/postgresql/data \
      -p 5432:5432 \
      postgres:9.6-alpine

    exit $?
    ;;

  start|stop)
    # Container must exist
    if [ $container_status -ne 0 ]; then
      echo "Error: container has not been created"
      exit 1
    fi

    echo "${cmd}ing container..."
    docker container "$cmd" jrvs-psql
    exit $?
    ;;

  *)
    echo "Illegal command"
    echo "Usage: ./psql_docker.sh start|stop|create [db_username] [db_password]"
    exit 1
    ;;
esac

