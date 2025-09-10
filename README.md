# README

## Development Setup

### 1. Environment Setup

Copy the example environment file and create your local `.env`:

```sh
cp .env.example .env
```

### 2. Common Commands

```sh
# Build and run containers (no cache)
docker-compose up --build --no-cache

# Run containers
docker-compose up

# Stop containers
docker-compose down

# Run containers in detached mode
docker-compose up -d

# Check logs
docker-compose logs

# Access Rails container bash
docker-compose exec api bash

# Run Rails migrations
docker-compose exec api bin/rails db:migrate

# Open Rails console
docker-compose exec api bin/rails c

# Production mode
# Build in production mode
docker-compose -f docker-compose.prod.yml --env-file .env.prod build --no-cache
# Start in production mode
docker-compose -f docker-compose.prod.yml --env-file .env.prod up
# Run migrations in production
docker-compose -f docker-compose.prod.yml --env-file .env.prod run --rm api bin/rails db:migrate
```

---

## Debug Mode

Rails runs in Docker without an attached TTY by default. To open an interactive shell for `binding.pry` or debugging:

```sh
bin/debug
```

`bin/debug` handles attaching to the container. Type `continue` to detach using `Ctrl-p Ctrl-q`. **Do not use Ctrl-c**, it will kill the container.

---

## Redis + Sidekiq

Redis and Sidekiq (sharing the Rails image) are added via Docker Compose. Ensure the environment is configured correctly with `{ROOT_FOLDER}-api:latest`.

---

## Adding / Removing Gems

### Adding Gems

1. Stop containers
2. Add gems to the `Gemfile`
3. Start containers again
4. `Gemfile.lock` will be updated automatically

> Note: In development mode, `bundle install` runs via the entrypoint each time the container restarts. In production, rely on the built image to avoid redundant installs.

### Removing Gems

1. Stop containers
2. Remove gems from the `Gemfile`
3. Start containers again
4. Ensure `Gemfile.lock` is updated
5. Commit both `Gemfile` and `Gemfile.lock`

---

## Production Mode

If you want to run production mode locally by allowing `http` requests on different port (as 80 is busy for local), set following env in your `.env.prod`
```sh
PORT=8080
SSL_REQUIRED=false
```

And test if it is working,
```sh
curl http://localhost:8080/health
```
You may need following commands,
```sh
# Build in production mode
docker-compose -f docker-compose.prod.yml --env-file .env.prod build --no-cache
# Start in production mode
docker-compose -f docker-compose.prod.yml --env-file .env.prod up
# DO not forget to run migrations in production manually
docker-compose -f docker-compose.prod.yml --env-file .env.prod run --rm api bin/rails db:migrate
```

---

## Logger Notes

Rails logs in production are sent to STDOUT. Configure CloudWatch Logs Agent or use the `awslogs` driver in Docker Compose with a retention period (e.g., 7, 14, or 30 days).

To manage logs manually, add the following to `config/environments/production.rb`:

```ruby
config.logger = Logger.new(
  Rails.root.join("log", "#{Rails.env}.log"),
  10,                  # Keep 10 rotated files
  50 * 1024 * 1024     # Max size 50 MB per file
)
```
