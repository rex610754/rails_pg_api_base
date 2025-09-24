# README

## Development Setup

### 1. Environment Setup

Copy the example environment file and create your local `.env`:

```sh
cp .env.example .env
```

### 2. Common Commands

```sh
# Build (no cache)
docker-compose build --no-cache

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

`bin/debug` attaches to the container. Type `continue` to detach using `Ctrl-p Ctrl-q`. **Do not use Ctrl-c**, as it will stop the container.

---

## Redis + Sidekiq

Redis and Sidekiq (sharing the Rails image) are included via Docker Compose. Ensure the environment is configured correctly with `{ROOT_FOLDER}-api:latest`.

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

<details>
<summary><strong>sample production .env for EC2 (t3.micro)</strong></summary>

```env
# Rails environment
RAILS_ENV=production
# SIDEKIQ_CONCURRENCY = 5
WEB_CONCURRENCY=2 # Ideally 4
RAILS_MAX_THREADS=5 # Ideally 10
SIDEKIQ_CONCURRENCY=1 # Ideally 5

# Rails secret key for production
SECRET_KEY_BASE=GENERATE_YOUR_OWN_SECRET_KEY
RAILS_API_IMAGE=rex610/gym_management_rails_prod_api:latest # Your own image

# Database configuration - Use strong credentials
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
DATABASE_NAME=gym_lms_production
DB_HOST=db
DB_PORT=5432

# Redis - If Redis is external, provide its URL and remove the Redis service from docker-compose.yml
REDIS_URL=redis://redis:6379/0

# Sidekiq Auth - Use strong credentials
SIDEKIQ_USERNAME=admin
SIDEKIQ_PASSWORD=T8w#z!Q7m@92fLrD^cVbh3Xp

BUNDLE_DEPLOYMENT=1
BUNDLE_WITHOUT=development:test
BUNDLE_FROZEN=true

# Set this only when running production mode locally.
# PORT=8080

# For staging without SSL; remove this if using an SSL certificate.
SSL_REQUIRED=false

# For CORS. Add your public IP if you need to access staging locally.
ALLOWED_ORIGINS=http://localhost:3000,http://<EC2_API_PUBLIC_IP>:3000,http://<YOUR_PUBLIC_IP>:3000
```

</details>

Test if it is working:

```sh
curl http://localhost:8080/health
```

You may need the following commands:

```sh
# Build in production mode - this will create an image to set in .env.prod
docker build --no-cache
# Start in production mode
docker-compose -f docker-compose.prod.yml --env-file .env.prod up
# Do not forget to run migrations in production manually
docker-compose -f docker-compose.prod.yml --env-file .env.prod run --rm api bin/rails db:migrate
```

### Deployment Notes (Production)

If deploying on an EC2 instance, create the Docker image locally for production.
Ensure you are not building the production image with unstaged changes or from the wrong branch.
Make sure you are matching your server architecture which is used to build production image with target server.
Added `build_prod_image.sh` to help you build the production docker image locally.

This makes it easy to pull the image on the EC2 server and run docker with `.env.prod` (copied via `scp`).
Later, we will implement a better way to manage production environment variables and automated deployments.

### Steps for EC2 Deployment

1. Create a directory on the EC2 server:
```sh
mkdir <your_api_project>
```

2. Copy the required files (assuming you have `pem_file.pem` for server access):
```sh
scp -i pem_file.pem .env.prod ec2-user@<public_ip>:/home/ec2-user/<your_api_project>/.env
scp -i pem_file.pem docker-compose.prod.yml ec2-user@<public_ip>:/home/ec2-user/<your_api_project>/docker-compose.yml
```

3. Run the following from `<your_api_project>` on the EC2 instance:
```sh
cd <your_api_project>
docker login # needed if your docker image is private
docker-compose pull
docker-compose up -d
docker ps
```

---

## Logger Notes

Rails logs in production are sent to STDOUT.
Configure CloudWatch Logs Agent or use the `awslogs` driver in Docker Compose with a retention period (e.g., 7, 14, or 30 days).

To manage logs manually, add the following to `config/environments/production.rb`:

```ruby
config.logger = Logger.new(
  Rails.root.join("log", "#{Rails.env}.log"),
  10,                  # Keep 10 rotated files
  50 * 1024 * 1024     # Max size 50 MB per file
)
```
