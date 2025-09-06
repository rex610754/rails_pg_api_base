#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /usr/src/app/tmp/pids/server.pid

# Wait for database to be ready
until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -U "$POSTGRES_USER" -c '\q' >/dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done

# Run migrations only in development
if [ "$RAILS_ENV" = "development" ]; then

  echo "Installing gems..."
  bundle install && bundle clean --force
  echo "Gems synced with Gemfile.lock."

  echo "Running in development - checking database and migrations..."
  # Check if database exists
  if ! PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$DB_HOST" -U "$POSTGRES_USER" -lqt | cut -d \| -f 1 | grep -qw "$DATABASE_NAME"; then
    echo "Database $DATABASE_NAME does not exist. Creating..."
    bundle exec rails db:create
  fi

  # Run migrations
  bundle exec rails db:migrate
else
  echo "Skipping automatic migrations in $RAILS_ENV mode."
  echo "⚠️  Remember to run: docker-compose run --rm api bin/rails db:migrate"
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@"
