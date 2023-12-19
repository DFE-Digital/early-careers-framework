/* eslint-disable import/extensions, import/no-unresolved */

import http from 'k6/http';
import { check, sleep } from 'k6';

import { fromEnv, randomIntBetween } from '../common/utils.js';

// eslint-disable-next-line import/prefer-default-export
export const apiBreakpointTest = () => {
  const targetDomain = `http://${fromEnv('TARGET_HOSTNAME')}:${fromEnv('TARGET_PORT')}`;
  const targetPath = fromEnv('TARGET_PATH') || "/api/v3/npq-applications";
  const apiToken = fromEnv('LEAD_PROVIDER_API_TOKEN');

  const headers= {
    'Authorization': `Bearer ${apiToken}`,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  //'X-With-Server-Date': '2023-02-10T02:21:32.000Z',
  };

  const uri = `${targetDomain}${targetPath}`;
  const tags = { targetDomain, targetPath };
  const params = { headers, tags, timeout: '900s' }; // 15mins

  const res = http.get(uri, params);
  check(res,
    {
      'is status 200': (r) => r.status === 200,
    },
    tags
  );
  sleep(randomIntBetween(globalThis.PAUSE_MIN, globalThis.PAUSE_MAX));
};
