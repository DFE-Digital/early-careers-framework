import http from 'k6/http';
import { check, sleep } from 'k6';
import { htmlReport } from 'https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js';

const perfTargetPath = '/';

export const options = {
  thresholds: {
    http_req_failed: ['rate<0.01'], // http errors should be less than 1%
    http_req_duration: ['p(95)<500'], // 95 percent of response times must be below 500ms
  },
  stages: [
    { duration: '60s', target: 10 }, // Warming up
    { duration: '240s', target: 200 }, // Ramping up
    { duration: '500s', target: 200 },  // Sustained load
  ],
};

export default function run() {
  const res = http.get(`http://${__ENV.PERF_TARGET_HOSTNAME}:${__ENV.PERF_TARGET_PORT}${perfTargetPath}`);
  check(res, { 'status was 200': (r) => r.status === 200 });
  sleep(1);
}

export function handleSummary(data) {
  return { '/report/landing-page-summary.html': htmlReport(data) };
}
