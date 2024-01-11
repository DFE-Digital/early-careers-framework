#!/bin/bash

export RAILS_ENV=performance

export SERVICE_NAME=early-careers-framework
export DATABASE_NAME=early_careers_framework_${RAILS_ENV}

export PERF_TARGET_HOSTNAME=localhost
export PERF_TARGET_PORT=3000

export PERF_LEAD_PROVIDER_API_TOKEN=performance-api-token
export PERF_SCENARIO=api-breakpoint-test
export PERF_REPORT_FILE=k6-output.json

# export PERF_TARGET_PATH="/api/v1/npq-applications",            # 68 in 170secs - duration max 123secs
# export PERF_TARGET_PATH="/api/v1/participants/npq/outcomes",   # 4825 in 170secs - duration max 43secs
# export PERF_TARGET_PATH="/api/v1/participants/npq",            # 30 in 170secs - duration max 44secs
# export PERF_TARGET_PATH="/api/v1/participant-declarations",    # 87 in 80secs - duration max 60secs
# export PERF_TARGET_PATH="/api/v1/participants/ecf",            # 9 in 50secs - duration max 26secs

# export PERF_TARGET_PATH="/api/v2/npq-applications",            # 15 in 70secs - duration max 60secs
# export PERF_TARGET_PATH="/api/v2/participants/npq/outcomes",   # 5147 in 170secs - duration max 39secs
# export PERF_TARGET_PATH="/api/v2/participants/npq",            # 5 inn 70secs - duration max 60secs
# export PERF_TARGET_PATH="/api/v2/participant-declarations",    # 83 in 80secs - duration max 60secs
# export PERF_TARGET_PATH="/api/v2/participants/ecf",            # 4 in 28ecs - duration max 22secs

export PERF_TARGET_PATH="/api//api/v3/npq-applications",       # 24 in 70secs - duration max 60s
# export PERF_TARGET_PATH="/api/v3/participants/npq/outcomes",   # 5514 in 170secs - duration max 38secs
# export PERF_TARGET_PATH="/api/v3/participants/npq",            # 34 in 70secs - duration max 60secs
# export PERF_TARGET_PATH="/api/v3/participant-declarations",    # 37 in 70secs - duration max 60secs
# export PERF_TARGET_PATH="/api/v3/participants/ecf",            # 12 in 250secs - user max 3, duration max 35secs

# export PERF_TARGET_PATH="/api/v3/delivery-partners",           # 14252 in 170secs - duration max 14secs
# export PERF_TARGET_PATH="/api/v3/partnerships/ecf",            # 66 in 80ecs - duration max 60secs
# export PERF_TARGET_PATH="/api/v3/participants/ecf/transfers",  # 713 in 110secs - duration max 60secs
# export PERF_TARGET_PATH="/api/v3/unfunded-mentors/ecf",        # 77 in 75secs - duration max 60secs
# export PERF_TARGET_PATH="/api/v3/statements",                  # 15771 in 180secs - duration max 15secs

mkdir ../reports
rm -fr ../reports/${PERF_SCENARIO}*

tar -zxvf ./db/sanitised-production.sql.gz -C ./db sanitised-production.sql

dropdb ${DATABASE_NAME}
createdb ${DATABASE_NAME}
psql ${DATABASE_NAME} < ./db/sanitised-production.sql
bundle exec rails db:migrate db:seed
bundle exec rails server -d

k6 run -main.js --out json=k6.log
mv ${PERF_REPORT_FILE} ../reports/${PERF_SCENARIO}-report.json
mv k6.log ../reports/${PERF_SCENARIO}.log

node dfe-k6-log-to-json.js ../reports ${PERF_SCENARIO}
node dfe-k6-reporter.js ../reports ${PERF_SCENARIO}

# shellcheck disable=SC2046
kill -9 $(cat ../tmp/pids/server.pid)
rm -fr ./db/sanitised-production.sql
