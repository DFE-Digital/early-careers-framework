/* eslint-disable import/extensions, import/no-unresolved */

import http from 'k6/http';
import { group, check, sleep } from 'k6';

import { randomIntBetween, fromEnv } from '../common/utils.js';

// eslint-disable-next-line import/prefer-default-export
export const apiLoadTest = () => {
  const path = '/participants/ecf';
  const totalParticipants = fromEnv('NUM_AUTHORITIES') * fromEnv('NUM_SCHOOLS') * fromEnv('NUM_PARTICIPANTS');
  const lastPage = Math.ceil(totalParticipants / 2000);

  // test params
  const headers= {
    'Authorization': `Bearer ${fromEnv('LEAD_PROVIDER_API_TOKEN')}`,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-With-Server-Date': '2023-02-10T02:21:32.000Z',
  };

  ['v1', 'v2', 'v3']
    .forEach(version => {
      const apiVersion = `API ${version}`;

      group(apiVersion, () => {
        [1, lastPage]
          .forEach(page => {
            const endpoint = `/api/${version}${path}`;
            const query = `page[page]=${page}&page[per_page]=${fromEnv('PARTICIPANTS_PER_PAGE')}`;
            const uri = `http://${fromEnv('TARGET_HOSTNAME')}:${fromEnv('TARGET_PORT')}${endpoint}?${query}`;

            const tags = { path, version, endpoint, query, page };
            const params = { headers, tags };

            group(endpoint, () => {

              const res = http.get(uri, params);
              check(res,
                {
                  'is status 200': (r) => r.status === 200,
                  'body size is less than 12,000 bytes': (r) => r.body.length < 12000,
                },
                tags
              );

              sleep(randomIntBetween(globalThis.PAUSE_MIN, globalThis.PAUSE_MAX));
            });
        });
      });
    });
}
