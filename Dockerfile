# To use or update to a ruby version, change {BASE_RUBY_IMAGE}
ARG BASE_RUBY_IMAGE=ruby:2.7.4-alpine
# BASE_RUBY_IMAGE_WITH_GEMS_AND_NODE_MODULES will default to early-careers-framework-gems-node-modules
# building all layers above it if a value is not specidied during the build
ARG BASE_RUBY_IMAGE_WITH_GEMS_AND_NODE_MODULES=early-careers-framework-gems-node-modules

FROM ${BASE_RUBY_IMAGE} AS middleman

RUN apk add --update --no-cache npm git build-base

COPY docs/Gemfile docs/Gemfile.lock /

RUN bundle install --jobs=4

COPY docs /docs
COPY public /public
COPY swagger /swagger

WORKDIR docs
RUN bundle exec middleman build --build-dir=../public/api-reference

# Stage 1: Download gems and node modules.
FROM ${BASE_RUBY_IMAGE} AS builder

ARG BUILD_DEPS="git gcc libc-dev make nodejs yarn postgresql-dev build-base libxml2-dev libxslt-dev"

WORKDIR /app

COPY Gemfile Gemfile.lock package.json yarn.lock .ruby-version ./

RUN apk -U upgrade && \
    apk add --update --no-cache --virtual .gem-installdeps $BUILD_DEPS && \
    gem update --system && \
    find / -wholename '*default/bundler-*.gemspec' -delete && \
    rm -rf /usr/local/bin/bundle && \
    gem install bundler -v 2.2.22 && \
    bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle --retry=5 --jobs=4 --without=development test && \
    yarn install --check-files --production && \
    apk del .gem-installdeps && \
    rm -rf /usr/local/bundle/cache && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete

# Stage 2: early-careers-framework-gems-node-modules, reduce size of gems-node-modules and only keep required files.
# published as dfedigital/early-careers-framework-gems-node-modules
FROM ${BASE_RUBY_IMAGE} AS early-careers-framework-gems-node-modules

RUN apk -U upgrade && \
    apk add --update --no-cache nodejs yarn tzdata libpq libxml2 libxslt graphviz && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Stage 3: assets-precompile, precomple assets and remove compile dependencies.
FROM ${BASE_RUBY_IMAGE_WITH_GEMS_AND_NODE_MODULES} AS assets-precompile

ENV GOVUK_APP_DOMAIN="http://localhost:3000" \
    GOVUK_WEBSITE_ROOT="http://localhost:3000" \
    RAILS_ENV=production \
    AUTHORISED_HOSTS=127.0.0.1 \
    SECRET_KEY_BASE=TestKey \
    IGNORE_SECRETS_FOR_BUILD=1

WORKDIR /app
COPY . .

RUN bundle exec rake assets:precompile && \
    apk del nodejs yarn && \
    rm -rf yarn.lock && \
    rm -rf tmp/* log/* node_modules /usr/local/share/.cache /tmp/*

# Stage 4: production, copy application code and compiled assets to base ruby image.
# Depends on assets-precompile stage which can be cached from a pre-built image
# by specifying a fully qualified image name or will default to packages-prod thereby rebuilding all 3 stages above.
# If a existing base image name is specified Stage 1 & 2 will not be built and gems and dev packages will be used from the supplied image.
FROM ${BASE_RUBY_IMAGE} AS production

ARG SHA
ENV AUTHORISED_HOSTS=127.0.0.1 \
    SHA=${SHA}

RUN apk -U upgrade && \
    apk add --update --no-cache tzdata libpq libxml2 libxslt graphviz && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

COPY --from=assets-precompile /app /app
COPY --from=assets-precompile /usr/local/bundle/ /usr/local/bundle/
COPY --from=middleman /public/ /app/public/

WORKDIR /app

# Use this for development testing
# CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0

# We migrate and ignore concurrent_migration_exceptions because we deploy to
# multiple instances at the same time.
#
# Under these conditions each instance will try to run migrations. Rails uses a
# database lock to prevent them stepping on each another. If they happen to,
# a ConcurrentMigrationError exception is thrown, the command exits 1, and
# the server will not start thanks to the shell &&.
#
# We swallow the exception and run the server anyway, because we prefer running
# new code on an old schema (which will be updated a moment later) to running
# old code on the new schema (which will require another deploy or other manual
# intervention to correct).
CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && bundle exec rails server -b 0.0.0.0
