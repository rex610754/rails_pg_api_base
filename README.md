# README

## Development Setup

We are using local UID to reflect docker reflect changes done by commands on docker container to local.

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

## Logger Note:

1. Rails logs for production is sent to STDOUT, and so configure CloudWatch Logs Agent (or awslogs driver in Docker Compose) with a retention period (e.g. 7, 14, 30 days). In case if you want to manage it manually. You need following configuration.
  ```sh
  config.logger = Logger.new(
    Rails.root.join("log", "#{Rails.env}.log"),
    10, # keep 10 rotated files
    50 * 1024 * 1024 # max size 50 MB per file
  )