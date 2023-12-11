#!/bin/bash

export RAILS_ENV=performance

export SERVICE_NAME=early-careers-framework
export DATABASE_NAME=${SERVICE_NAME}_${RAILS_ENV}

export PERF_TARGET_HOSTNAME=localhost
export PERF_TARGET_PORT=3000
export PERF_LEAD_PROVIDER_API_TOKEN=performance-api-token

export PERF_NUM_AUTHORITIES=10
export PERF_NUM_SCHOOLS=10
export PERF_NUM_PARTICIPANTS=10

export PERF_SCENARIO=api-load-test
export PERF_REPORT_FILE=k6-output.json

mkdir ./reports
rm -fr ./reports/${PERF_SCENARIO}*

tar -zxvf ./performance/db/sanitised-production.sql.gz -C ./performance/db sanitised-production.sql

createdb ${DATABASE_NAME}
psql ${DATABASE_NAME} < ./performance/db/sanitised-production.sql
bundle exec rails db:migrate db:seed
bundle exec rails server -d

cd ./performance || exit

k6 run ./main.js --out json=../reports/${PERF_SCENARIO}.log
mv ./${PERF_REPORT_FILE} ../reports/${PERF_SCENARIO}-report.json

node dfe-k6-log-to-json.js ../reports/${PERF_SCENARIO}.log ../reports/${PERF_SCENARIO}-log.json
node dfe-k6-reporter.js ../reports/${PERF_SCENARIO}-report.json ../reports/${PERF_SCENARIO}-report.html ../reports/${PERF_SCENARIO}-summary.md

cd .. || exit

# shellcheck disable=SC2046
kill -9 $(cat tmp/pids/server.pid)
rm -fr ./db/sanitised-production.sql
