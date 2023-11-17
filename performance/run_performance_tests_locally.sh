export IMAGE=ghcr.io/dfe-digital/early-careers-framework:1980b11829bde48805fa53c568a6f994ae33246b

export PERF_NUM_AUTHORITIES=10
export PERF_NUM_SCHOOLS=100
export PERF_NUM_PARTICIPANTS=10

export PERF_SCENARIO=api-load-test
export PERF_REPORT_FILE=k6-output.json

node dfe-k6-log-to-json.js ../reports/${PERF_SCENARIO}.log ../reports/${PERF_SCENARIO}-log.json
node dfe-k6-reporter.js ../reports/${PERF_SCENARIO}-report.json ../reports/${PERF_SCENARIO}-report.html ../reports/${PERF_SCENARIO}-summary.md

