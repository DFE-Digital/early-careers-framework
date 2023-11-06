export IMAGE=ghcr.io/dfe-digital/early-careers-framework:1980b11829bde48805fa53c568a6f994ae33246b

export PERF_NUM_AUTHORITIES=1
export PERF_NUM_SCHOOLS=1
export PERF_NUM_PARTICIPANTS=1

export PERF_SCENARIO=smoke-test
export PERF_REPORT_FILE=k6-output.json

rm -fr ./reports
mkdir ./reports

docker-compose up -d web
docker-compose up seed
docker-compose up k6
docker-compose cp k6:/home/k6/${PERF_REPORT_FILE} ./reports/${PERF_SCENARIO}-summary.json

node ./html-reporter.js ./reports/${PERF_SCENARIO}-summary.json ./reports/${PERF_SCENARIO}-summary.html

docker-compose down
