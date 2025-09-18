# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.1.0
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /usr/src/app

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl libjemalloc2 libvips postgresql-client build-essential libpq-dev nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

### Build stage: install gems
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev pkg-config \
      libxml2-dev libxslt-dev zlib1g-dev libffi-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set env here so gems are installed the same way they will be used in final stage
ENV BUNDLE_PATH=/usr/local/bundle

# Install only gems first (better caching)
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=4 --retry=3 && \
    rm -rf ~/.bundle/ /usr/local/bundle/ruby/*/cache /usr/local/bundle/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

### Final stage: app image
FROM base

# Default to production in final image
ENV BUNDLE_PATH=/usr/local/bundle

ENV UID=1000
ENV GID=1000

# Copy built artifacts
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /usr/src/app /usr/src/app

# Create non-root user
RUN groupadd --system --gid ${GID} rails && \
    useradd rails --uid ${UID} --gid ${GID} --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp && \
    chown -R rails:rails /usr/local/bundle

# Entrypoint
COPY entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && chown rails:rails /docker-entrypoint.sh

USER ${UID}:${GID}

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
