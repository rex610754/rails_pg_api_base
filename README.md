# README

## Development Setup

1. Copy the example environment file and create your local `.env`:
   ```sh
   cp .env.example .env

2. Build and start the containers:
   ```sh
   ./docker-build.sh

3. Access the Rails container (if needed):
   ```sh
   docker-compose exec api bash

4. Run Rails commands inside the container, for example:
   ```sh
   docker-compose exec api bin/rails db:create db:migrate