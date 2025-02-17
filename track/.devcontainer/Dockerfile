# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.2
FROM ruby:$RUBY_VERSION As dev_builder

ENV LANG C.UTF-8
ENV BUNDLE_DEPLOYMENT="1"
ENV BUNDLE_PATH="vendor/bundle"
ENV RUBYOPT="--yjit"

# RUN groupadd -r wevox && useradd -r -g wevox wevox
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

ENV APP_ROOT=/usr/src/app
RUN mkdir ${APP_ROOT}

# 2.5.15
RUN gem install bundler -v 2.5.15

# Install application gems
COPY ../Gemfile ../Gemfile.lock /usr/src/app/
WORKDIR /usr/src/app
RUN bundle install

# Install node modules
#COPY ../vendor/package.json ../vendor/yarn.lock /usr/src/app/vendor/
#WORKDIR /usr/src/app/vendor
#RUN yarn install

#FROM dev_builder AS dev_build

WORKDIR ${APP_ROOT}

EXPOSE 3000
