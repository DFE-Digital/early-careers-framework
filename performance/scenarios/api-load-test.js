/* eslint-disable import/extensions, import/no-unresolved */

import http from 'k6/http';
import { group, check, sleep } from 'k6';

import { randomIntBetween, fromEnv } from '../common/utils.js';

// eslint-disable-next-line import/prefer-default-export
export const apiLoadTest = () => {
  const targetDomain = `http://${fromEnv('TARGET_HOSTNAME')}:${fromEnv('TARGET_PORT')}`;
  const targetPath = '/participants/ecf';

  const totalParticipants = fromEnv('TOTAL_PARTICIPANTS');
  const participantsPerPage = fromEnv('PARTICIPANTS_PER_PAGE');
  const lastPage = Math.ceil(totalParticipants / participantsPerPage);

  const apiToken = fromEnv('LEAD_PROVIDER_API_TOKEN');

  // test params
  const headers= {
    'Authorization': `Bearer ${apiToken}`,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  //'X-With-Server-Date': '2023-02-10T02:21:32.000Z',
  };

  ['v1', 'v2', 'v3']
    .forEach(version => {
      const apiVersion = `API ${version}`;

      group(apiVersion, () => {
        ['first', 'last']
          .forEach(page => {
            const pageNumber = page === 'first' ? 1 : lastPage;
            const endpoint = `/api/${version}${targetPath}`;
            const query = `page[page]=${pageNumber}&page[per_page]=${participantsPerPage}`;
            const uri = `${targetDomain}${endpoint}?${query}`;

            const tags = { path: targetPath, version, endpoint, query, page, pageNumber };
            const params = { headers, tags };

            group(`${targetPath}?page[page]=${page}`, () => {
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
