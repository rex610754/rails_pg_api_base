#!/bin/bash
set -e

# Always pass UID for dev builds (not needed in prod)
export LOCAL_UID=$(id -u)

case "$1" in
  build)
    docker-compose up --build
    ;;
  up)
    docker-compose up
    ;;
  down)
    docker-compose down
    ;;
    logs)
    docker-compose logs -f
    ;;
  *)
    echo "Usage: $0 {build|up|down}"
    exit 1
    ;;
esac

