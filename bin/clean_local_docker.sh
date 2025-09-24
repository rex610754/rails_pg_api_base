# Stop all running containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm -f $(docker ps -aq)

# Remove all images
docker rmi -f $(docker images -aq)

# Remove all volumes
docker volume rm $(docker volume ls -q)

# Remove all networks (except default ones: bridge, host, none)
docker network rm $(docker network ls -q)

# Prune builders (build cache)
docker builder prune -a -f

# Final system prune
docker system prune -a --volumes -f