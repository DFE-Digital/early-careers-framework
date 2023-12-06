#!/bin/bash

export SERVICE_NAME=early-careers-framework
export DATABASE_NAME=early_careers_framework_performance

export IMAGE=ghcr.io/dfe-digital/early-careers-framework:main

export PERF_NUM_AUTHORITIES=10
export PERF_NUM_SCHOOLS=10
export PERF_NUM_PARTICIPANTS=10

export PERF_SCENARIO=api-load-test
export PERF_REPORT_FILE=k6-output.json

mkdir ../reports
rm -fr ../reports/${PERF_SCENARIO}*

# docker compose build
docker compose up -d web

if [ -f ./db/${SERVICE_NAME}-full.sql ]; then
  echo "restoring performance database from dump"
  docker compose exec -T db psql --username postgres ${DATABASE_NAME} < ./db/${SERVICE_NAME}-full.sql

  echo "Migrating db schema"
  docker compose exec web bundle exec rails db:migrate:primary
else
  echo "Running db seed"
  docker compose exec web bundle exec rails db:create db:schema:load
  docker compose exec web bundle exec rails db:seed
fi

docker compose up k6
docker compose cp k6:/home/k6/${PERF_REPORT_FILE} ../reports/${PERF_SCENARIO}-report.json
docker compose cp k6:/home/k6/k6.log ../reports/${PERF_SCENARIO}.log

node dfe-k6-log-to-json.js ../reports/${PERF_SCENARIO}.log ../reports/${PERF_SCENARIO}-log.json
node dfe-k6-reporter.js ../reports/${PERF_SCENARIO}-report.json ../reports/${PERF_SCENARIO}-report.html ../reports/${PERF_SCENARIO}-summary.md

docker compose down -v
