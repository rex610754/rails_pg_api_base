#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /rails/tmp/pids/server.pid

# Wait for database to be ready
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "db" -U "postgres" -c '\q'; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done

# Check if database exists
if ! PGPASSWORD=$POSTGRES_PASSWORD psql -h "db" -U "postgres" -lqt | cut -d \| -f 1 | grep -qw "$DATABASE_NAME"; then
  echo "Database $DATABASE_NAME does not exist. Creating..."
  bundle exec rails db:create
fi

# Run migrations
bundle exec rails db:migrate

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@"