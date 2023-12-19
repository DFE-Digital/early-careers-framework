#!/bin/bash

export RAILS_ENV=performance

export SERVICE_NAME=early-careers-framework
export DATABASE_NAME=early_careers_framework_${RAILS_ENV}

export PERF_TARGET_HOSTNAME=localhost
export PERF_TARGET_PORT=3000

# export PERF_LEAD_PROVIDER_API_TOKEN=performance-api-token
# export PERF_SCENARIO=api-breakpoint-test

export PERF_SCENARIO=breakpoint-test

export PERF_REPORT_FILE=k6-output.json

mkdir ../reports
rm -fr ../reports/${PERF_SCENARIO}*

tar -zxvf ./db/sanitised-production.sql.gz -C ./db sanitised-production.sql

createdb ${DATABASE_NAME}
psql ${DATABASE_NAME} < ./db/sanitised-production.sql
bundle exec rails db:migrate db:seed
bundle exec rails server -d

k6 run ./main.js --out json=../reports/${PERF_SCENARIO}.log
mv ./${PERF_REPORT_FILE} ../reports/${PERF_SCENARIO}-report.json

node dfe-k6-log-to-json.js ../reports/ ${PERF_SCENARIO}
node dfe-k6-reporter.js ../reports/ ${PERF_SCENARIO}

# shellcheck disable=SC2046
kill -9 $(cat tmp/pids/server.pid)
rm -fr ./db/sanitised-production.sql
