export IMAGE=ghcr.io/dfe-digital/early-careers-framework:1980b11829bde48805fa53c568a6f994ae33246b

export PERF_NUM_AUTHORITIES=152
export PERF_NUM_SCHOOLS=79
export PERF_NUM_PARTICIPANTS=3

export PERF_SCENARIO=api-load-test
export PERF_REPORT_FILE=k6-output.json

rm -fr ../reports
mkdir ../reports

docker-compose up -d web
docker-compose up seed
docker-compose up k6
docker-compose cp k6:/home/k6/${PERF_REPORT_FILE} ../reports/${PERF_SCENARIO}-report.json
docker-compose cp k6:/home/k6/k6.log ../reports/${PERF_SCENARIO}.log

node dfe-k6-log-to-json.js ../reports/${PERF_SCENARIO}.log ../reports/${PERF_SCENARIO}-log.json
node dfe-k6-reporter.js ../reports/${PERF_SCENARIO}-report.json ../reports/${PERF_SCENARIO}-report.html ../reports/${PERF_SCENARIO}-summary.md

docker-compose down
