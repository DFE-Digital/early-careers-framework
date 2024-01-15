/* eslint-disable import/extensions, import/no-unresolved */

import http from 'k6/http';
import { check, group } from 'k6';

import { fromEnv } from '../common/utils.js';

// eslint-disable-next-line import/prefer-default-export
export const getSuccessfulResponseFromWebPage = () => {
  const targetDomain = `http://${fromEnv('TARGET_HOSTNAME')}:${fromEnv('TARGET_PORT')}`;
  const targetPath = fromEnv('TARGET_PATH') || "/";

  const uri = `${targetDomain}${targetPath}`;
  const tags = { name: targetPath, path: targetPath };
  const params = { tags, timeout: '600s' };

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
};
