#!/bin/bash

export RAILS_ENV=performance

export SERVICE_NAME=early-careers-framework
export DATABASE_NAME=${SERVICE_NAME}_${RAILS_ENV}

export IMAGE=ghcr.io/dfe-digital/early-careers-framework:main

export PERF_NUM_AUTHORITIES=10
export PERF_NUM_SCHOOLS=10
export PERF_NUM_PARTICIPANTS=10

export PERF_SCENARIO=api-load-test
export PERF_REPORT_FILE=k6-output.json

mkdir ../reports
rm -fr ../reports/${PERF_SCENARIO}*

tar -zxvf ./db/sanitised-production.sql.gz -C ./db sanitised-production.sql

docker compose up -d web
docker compose exec -T db createdb --username postgres ${DATABASE_NAME}
docker compose exec -T db psql --username postgres ${DATABASE_NAME} < ./db/sanitised-production.sql
docker compose exec web bundle exec rails db:migrate db:seed

docker compose up k6
docker compose cp k6:/home/k6/${PERF_REPORT_FILE} ../reports/${PERF_SCENARIO}-report.json
docker compose cp k6:/home/k6/k6.log ../reports/${PERF_SCENARIO}.log

node dfe-k6-log-to-json.js ../reports/${PERF_SCENARIO}.log ../reports/${PERF_SCENARIO}-log.json
node dfe-k6-reporter.js ../reports/${PERF_SCENARIO}-report.json ../reports/${PERF_SCENARIO}-report.html ../reports/${PERF_SCENARIO}-summary.md

docker compose down -v
rm -fr ./db/sanitised-production.sql
