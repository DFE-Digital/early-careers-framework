#!/bin/bash

export RAILS_ENV=performance

export SERVICE_NAME=early-careers-framework
export DATABASE_NAME=early_careers_framework_${RAILS_ENV}

export IMAGE=ghcr.io/dfe-digital/early-careers-framework:main

export PERF_LEAD_PROVIDER_API_TOKEN=performance-api-token
export PERF_SCENARIO=api-load-test
export PERF_REPORT_FILE=k6-output.json

export PERF_TARGET_PATHS="/api/v1/npq-applications
/api/v1/participants/npq/outcomes
/api/v1/participants/npq
/api/v1/participant-declarations
/api/v1/participants/ecf
/api/v2/npq-applications
/api/v2/participants/npq/outcomes
/api/v2/participants/npq
/api/v2/participant-declarations
/api/v2/participants/ecf
/api/v3/npq-applications
/api/v3/participants/npq/outcomes
/api/v3/participants/npq
/api/v3/participant-declarations
/api/v3/participants/ecf
/api/v3/delivery-partners
/api/v3/partnerships/ecf
/api/v3/participants/ecf/transfers
/api/v3/unfunded-mentors/ecf
/api/v3/statements"

mkdir ../reports
rm -fr ../reports/${PERF_SCENARIO}*

tar -zxvf ./db/sanitised-production.sql.gz -C ./db sanitised-production.sql

docker compose up -d db
sleep 5

docker compose exec -T db createdb --username postgres early_careers_framework_performance
docker compose exec -T db createdb --username postgres early_careers_framework_analytics_performance
docker compose exec -T db psql --username postgres early_careers_framework_performance < ./db/sanitised-production.sql
sleep 5

docker compose up -d web
docker compose exec web bundle exec rails db:migrate db:seed
sleep 5

count=0
while read -r path; do
  (( count++ ))
  export PERF_TARGET_PATH=${path}

  printf '%d %s\n' "$count" "${path}"

  docker compose up k6
  docker compose cp k6:/home/k6/k6-output.json ../reports/${PERF_SCENARIO}-report.json
  docker compose cp k6:/home/k6/k6.log ../reports/${PERF_SCENARIO}-${count}.log
  cat ../reports/${PERF_SCENARIO}-${count}.log >> ../reports/${PERF_SCENARIO}.log
  rm ../reports/${PERF_SCENARIO}-${count}.log
  sleep 5
done <<< "$PERF_TARGET_PATHS"

node dfe-k6-log-to-json.js ../reports ${PERF_SCENARIO}
node dfe-k6-reporter.js ../reports ${PERF_SCENARIO}

docker compose down -v
rm -fr ./db/sanitised-production.sql
