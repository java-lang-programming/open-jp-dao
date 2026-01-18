# syntax = docker/dockerfile:1

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t my-app .
# docker run -d -p 80:80 -p 443:443 --name my-app -e RAILS_MASTER_KEY=<value from config/master.key> my-app

# =========================
# 1. runtime base
# =========================
# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=4.0.1
FROM ruby:$RUBY_VERSION-slim AS runtime

# Rails app lives here
WORKDIR /rails

#      libffi8 \
#      libsodium23 \
# Install base packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      libjemalloc2 \
      libvips \
      sqlite3 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    SOLID_QUEUE_IN_PUMA="1" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    LANG="C.UTF-8" \
    RUBYOPT="--yjit"

# =========================
# 2. build stage
# =========================
# Throw-away build stage to reduce size of final image
FROM runtime AS rails_build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libyaml-dev \
    libffi-dev \
    libsodium-dev \
    libsqlite3-dev \
    pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/


# =========================
# 3. Production stage
# =========================
# Final stage for app image
FROM runtime

# Copy built artifacts: gems, application
COPY --from=rails_build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=rails_build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
