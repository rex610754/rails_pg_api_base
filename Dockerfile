# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.1.0
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here (changed from /rails → /usr/src/app)
WORKDIR /usr/src/app

# Install base packages and system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client build-essential libpq-dev nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/


# Final stage for app image
FROM base

# Fixed UID/GID values
ENV UID=1000
ENV GID=1000

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /usr/src/app /usr/src/app

# Create non-root user with fixed UID/GID
RUN groupadd --system --gid ${GID} rails && \
    useradd rails --uid ${UID} --gid ${GID} --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

# Copy and setup entrypoint script into a safe path outside volume mount
COPY entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && \
    chown rails:rails /docker-entrypoint.sh

USER ${UID}:${GID}

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000
# Run Puma by default for production, unless overridden from docker-compose
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
