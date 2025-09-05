#!/bin/bash
export LOCAL_UID=$(id -u)
docker-compose --env-file .env.dev up --build