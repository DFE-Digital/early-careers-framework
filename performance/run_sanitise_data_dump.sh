#!/bin/bash

export SERVICE_NAME=early-careers-framework
export DATABASE_NAME=early_careers_framework_performance

export IMAGE=ghcr.io/dfe-digital/early-careers-framework:main

# docker compose build
docker compose up -d web

if [ -f ./db/${SERVICE_NAME}-full.sql ]; then
  echo "::group::Restore backup to intermediate database"
  docker compose exec -T db psql --username postgres ${DATABASE_NAME} < ./db/${SERVICE_NAME}-full.sql
  echo "::endgroup::"

  echo "::group::Sanitise data"
  docker compose exec -T db psql --username postgres ${DATABASE_NAME} < ../db/scripts/sanitise.sql
  echo "::endgroup::"

  echo "::group::Backup Sanitised Database"
  docker compose exec db pg_dump --username postgres ${DATABASE_NAME} > ./db/${SERVICE_NAME}-sanitised.sql
  tar -cvzf ./db/${SERVICE_NAME}-sanitised.tar.gz ./db/${SERVICE_NAME}-sanitised.sql
  echo "::endgroup::"
fi

docker compose down -v
