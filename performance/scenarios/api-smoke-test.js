/* eslint-disable import/extensions, import/no-unresolved */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { URL } from 'https://jslib.k6.io/url/1.0.0/index.js';

import { fromEnv, randomIntBetween } from '../common/utils.js';

const paths = [
  // Version 1
  '/api/v1/participants/ecf',
  '/api/v1/npq-applications',
  '/api/v1/participants/npq',
  '/api/v1/participants/npq/outcomes',
  '/api/v1/participant-declarations',

  // Version 2
  '/api/v2/participants/ecf',
  '/api/v2/npq-applications',
  '/api/v2/participants/npq',
  '/api/v2/participants/npq/outcomes',
  '/api/v2/participant-declarations',

  // Version 3
  '/api/v3/participants/ecf',
  '/api/v3/npq-applications',
  '/api/v3/participants/npq',
  '/api/v3/participants/npq/outcomes',
  '/api/v3/participant-declarations',
];

// eslint-disable-next-line import/prefer-default-export
export const apiSmokeTest = () => {
  const targetDomain = `http://${fromEnv('TARGET_HOSTNAME')}:${fromEnv('TARGET_PORT')}`;

  const apiToken = fromEnv('LEAD_PROVIDER_API_TOKEN');

  // test params
  const headers= {
    'Authorization': `Bearer ${apiToken}`,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  //'X-With-Server-Date': '2023-02-10T02:21:32.000Z',
  };

  paths.forEach(targetPath => {
    const uri = `${targetDomain}${targetPath}`;
    const tags = { targetDomain, targetPath };
    const params = { headers, tags, targetPath, timeout: '30s' };

    const url = new URL(uri);
    url.searchParams.append('page[page]', '5');
    url.searchParams.append('page[per_page]', '2000');

    const res = http.get(url.toString(), params);
    check(res,
      {
        'is status 200': (r) => r.status === 200,
      },
      tags
    );

    sleep(randomIntBetween(globalThis.PAUSE_MIN, globalThis.PAUSE_MAX));
  });
};
