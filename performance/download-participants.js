import http from 'k6/http';
import { group, check, sleep } from 'k6';
import { htmlReport } from 'https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js';

const hostname = __ENV.PERF_TARGET_HOSTNAME;
const port = __ENV.PERF_TARGET_PORT;
const numAuthorities = 1 * __ENV.PERF_NUM_AUTHORITIES;
const numSchools = 1 * __ENV.PERF_NUM_SCHOOLS;
const numParticipants = 1 * __ENV.PERF_NUM_PARTICIPANTS;
const totalParticipants = numAuthorities * numSchools * numParticipants;
const participantsPerPage = 2000;
const lastPage = Math.ceil(totalParticipants / participantsPerPage);

// test params
const headers= {
  'Authorization': 'Bearer performance-api-token', // `Bearer ${__ENV.PERF_LEAD_PROVIDER_API_TOKEN}`,
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'X-With-Server-Date': '2023-02-10T02:21:32.000Z',
};

export const options = {
  duration: '60s',  // Sustained load
  target: 5,        // consecutive users
  thresholds: {
    [`checks{status:200,version:v1,page:1}`]: ['rate>0.99'], // http errors should be less than 1%
    [`checks{status:200,version:v1,page:${lastPage}}`]: ['rate>0.99'], // http errors should be less than 1%
    [`checks{status:200,version:v2,page:1}`]: ['rate>0.99'], // http errors should be less than 1%
    [`checks{status:200,version:v2,page:${lastPage}}`]: ['rate>0.99'], // http errors should be less than 1%
    [`checks{status:200,version:v3,page:1}`]: ['rate>0.99'], // http errors should be less than 1%
    [`checks{status:200,version:v3,page:${lastPage}}`]: ['rate>0.99'], // http errors should be less than 1%

    [`http_req_duration{version:v1,page:1}`]: ['p(95)<500'], // 95 percent of response times must be below 500ms
    [`http_req_duration{version:v1,page:${lastPage}}`]: ['p(95)<500'], // 95 percent of response times must be below 500ms
    [`http_req_duration{version:v2,page:1}`]: ['p(95)<500'], // 95 percent of response times must be below 500ms
    [`http_req_duration{version:v2,page:${lastPage}}`]: ['p(95)<500'], // 95 percent of response times must be below 500ms
    [`http_req_duration{version:v3,page:1}`]: ['p(95)<500'], // 95 percent of response times must be below 500ms
    [`http_req_duration{version:v3,page:${lastPage}}`]: ['p(95)<500'], // 95 percent of response times must be below 500ms
  },
};

export default function run() {
  const versions = ['v1', 'v2', 'v3'];
  const pages = [1, lastPage];

  const path = '/participants/ecf';

  versions.forEach(version => {
    group(`API ${version}`, () => {
      pages.forEach(page => {
        const params = {
          headers,
          tags: { path, version, page }
        };

        const query = `page[page]=${page}&page[per_page]=${participantsPerPage}`;

        const res = http.get(`http://${hostname}:${port}/api/${version}${path}?${query}`, params);
        check(
          res,
          { 'status is 200': (r) => r.status === 200 },
          { status: 200, version, page }
        );
        sleep(1);
      });
    });
  });
}

export function handleSummary(data) {
  return { '/report/download-participants-summary.html': htmlReport(data) };
}
