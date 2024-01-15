#!/bin/bash

export RAILS_ENV=performance

export SERVICE_NAME=early-careers-framework
export DATABASE_NAME=early_careers_framework_${RAILS_ENV}

export IMAGE=ghcr.io/dfe-digital/early-careers-framework:main

export PERF_LEAD_PROVIDER_API_TOKEN=performance-api-token
export PERF_SCENARIO=api-breakpoint-test
export PERF_REPORT_FILE=k6-output.json

export PERF_TARGET_PATH=/api/v1/npq-applications            # 68 in 170secs - duration max 123secs
# export PERF_TARGET_PATH=/api/v1/participants/npq/outcomes   # 4825 in 170secs - duration max 43secs
# export PERF_TARGET_PATH=/api/v1/participants/npq            # 30 in 170secs - duration max 44secs
# export PERF_TARGET_PATH=/api/v1/participant-declarations    # 87 in 80secs - duration max 60secs
# export PERF_TARGET_PATH=/api/v1/participants/ecf            # 9 in 50secs - duration max 26secs

# export PERF_TARGET_PATH=/api/v2/npq-applications            # 15 in 70secs - duration max 60secs
# export PERF_TARGET_PATH=/api/v2/participants/npq/outcomes   # 5147 in 170secs - duration max 39secs
# export PERF_TARGET_PATH=/api/v2/participants/npq            # 5 inn 70secs - duration max 60secs
# export PERF_TARGET_PATH=/api/v2/participant-declarations    # 83 in 80secs - duration max 60secs
# export PERF_TARGET_PATH=/api/v2/participants/ecf            # 4 in 28ecs - duration max 22secs

# export PERF_TARGET_PATH=/api/v3/npq-applications            # 24 in 70secs - duration max 60s
# export PERF_TARGET_PATH=/api/v3/participants/npq/outcomes   # 5514 in 170secs - duration max 38secs
# export PERF_TARGET_PATH=/api/v3/participants/npq            # 34 in 70secs - duration max 60secs
# export PERF_TARGET_PATH=/api/v3/participant-declarations    # 37 in 70secs - duration max 60secs
# export PERF_TARGET_PATH=/api/v3/participants/ecf            # 12 in 250secs - user max 3, duration max 35secs

# export PERF_TARGET_PATH=/api/v3/delivery-partners           # 14252 in 170secs - duration max 14secs
# export PERF_TARGET_PATH=/api/v3/partnerships/ecf            # 66 in 80ecs - duration max 60secs
# export PERF_TARGET_PATH=/api/v3/participants/ecf/transfers  # 713 in 110secs - duration max 60secs
# export PERF_TARGET_PATH=/api/v3/unfunded-mentors/ecf        # 77 in 75secs - duration max 60secs
# export PERF_TARGET_PATH=/api/v3/statements                  # 15771 in 180secs - duration max 15secs

mkdir ../reports
rm -fr ../reports/${PERF_SCENARIO}*

tar -zxvf ./db/sanitised-production.sql.gz -C ./db sanitised-production.sql

docker compose up -d web
sleep 1

docker compose exec -T db createdb --username postgres early_careers_framework_performance
docker compose exec -T db createdb --username postgres early_careers_framework_analytics_performance
docker compose exec -T db psql --username postgres early_careers_framework_performance < ./db/sanitised-production.sql
docker compose exec web bundle exec rails db:migrate db:seed
sleep 1

docker compose up k6
docker compose cp k6:/home/k6/k6-output.json ../reports/${PERF_SCENARIO}-report.json
docker compose cp k6:/home/k6/k6.log ../reports/${PERF_SCENARIO}.log

docker compose down -v
rm -fr ./db/sanitised-production.sql

node dfe-k6-log-to-json.js ../reports ${PERF_SCENARIO}
node dfe-k6-reporter.js ../reports ${PERF_SCENARIO}
