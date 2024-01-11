/* eslint-disable import/extensions, import/no-unresolved */

import http from 'k6/http';
import { check } from 'k6';
import { URL } from 'https://jslib.k6.io/url/1.0.0/index.js';

import { fromEnv } from '../common/utils.js';

// eslint-disable-next-line import/prefer-default-export
export const apiBreakpointTest = () => {
  const targetDomain = `http://${fromEnv('TARGET_HOSTNAME')}:${fromEnv('TARGET_PORT')}`;
  const targetPath = fromEnv('TARGET_PATH') || "/api/v3/participants/ecf";
  const apiToken = fromEnv('LEAD_PROVIDER_API_TOKEN');

  const headers= {
    'Authorization': `Bearer ${apiToken}`,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  //'X-With-Server-Date': '2023-02-10T02:21:32.000Z',
  };

  const uri = `${targetDomain}${targetPath}`;
  const tags = { name: targetPath, path: targetPath };
  const params = { headers, tags, timeout: '600s' };

  const url = new URL(uri);
  url.searchParams.append('page[page]', '5');
  url.searchParams.append('page[per_page]', '2000');

  group(`${targetPath}`, () => {
    const res = http.get(url.toString(), params);
    check(res,
      {
        'is status 200': (r) => r.status === 200,
      },
      tags
    );
  });
};
