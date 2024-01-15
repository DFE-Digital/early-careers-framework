/* eslint-disable import/extensions, import/no-unresolved */

import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { URL } from 'https://jslib.k6.io/url/1.0.0/index.js';

import { fromEnv, randomIntBetween } from '../common/utils.js';

const paths = [
  '/',
  '/privacy-policy',
  '/cookies',
  '/accessibility-statement',
  '/lead-providers',
  '/lead-providers/partnership-guide',
  '/api-reference'
];

// eslint-disable-next-line import/prefer-default-export
export const smokeTest = () => {
  const targetDomain = `http://${fromEnv('TARGET_HOSTNAME')}:${fromEnv('TARGET_PORT')}`;

  paths.forEach(targetPath => {
    const uri = `${targetDomain}${targetPath}`;
    const tags = { name: targetPath, path: targetPath };
    const params = { tags, timeout: '60s' };

    const url = new URL(uri);

    group(`${targetPath}`, () => {
      const res = http.get(url.toString(), params);
      check(res,
        {
          'response_status_200': (r) => r.status === 200,
        },
        tags
      );
    });

    sleep(randomIntBetween(globalThis.PAUSE_MIN, globalThis.PAUSE_MAX));
  });
};
