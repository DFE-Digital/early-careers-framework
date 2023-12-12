#!/bin/bash

export IMAGE=ghcr.io/dfe-digital/early-careers-framework:main

export PERF_SCENARIO=smoke-test

mkdir ../reports
rm -fr ../reports/${PERF_SCENARIO}*

tar -zxvf ./db/sanitised-production.sql.gz -C ./db sanitised-production.sql

docker compose up -d web
sleep 5

docker compose exec -T db createdb --username postgres early_careers_framework_performance
docker compose exec -T db createdb --username postgres early_careers_framework_analytics_performance
docker compose exec -T db psql --username postgres early_careers_framework_performance < ./db/sanitised-production.sql
docker compose exec web bundle exec rails db:migrate db:seed

docker compose up k6
docker compose cp k6:/home/k6/k6-output.json ../reports/${PERF_SCENARIO}-report.json
docker compose cp k6:/home/k6/k6.log ../reports/${PERF_SCENARIO}.log

node dfe-k6-log-to-json.js ../reports/${PERF_SCENARIO}.log ../reports/${PERF_SCENARIO}-log.json
node dfe-k6-reporter.js ../reports/${PERF_SCENARIO}-report.json ../reports/${PERF_SCENARIO}-report.html ../reports/${PERF_SCENARIO}-summary.md

docker compose down -v
rm -fr ./db/sanitised-production.sql
