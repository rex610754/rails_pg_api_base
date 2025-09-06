# README

## Development Setup

1. Copy the example environment file and create your local `.env`:
   ```sh
   cp .env.example .env

2. Build and start the containers:
   ```sh
   ./docker.sh build

3. Start:
   ```sh
   ./docker.sh up

4. Start in detached mode:
   ```sh
   ./docker.sh up-d

5. Stop:
   ```sh
   ./docker.sh down

6. Logs:
   ```sh
   ./docker.sh logs

7. Access the Rails container (if needed):
   ```sh
   ./docker.sh exec api bash

8. Run Rails commands inside the container, for example:
   ```sh
   docker-compose exec api bin/rails db:create db:migrate
   # OR
   ./docker.sh exec api bin/rails db:create db:migrate