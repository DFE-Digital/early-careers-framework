/* eslint-disable import/extensions, import/no-unresolved */

import http from 'k6/http';
import { check, sleep } from 'k6';

import { fromEnv, randomIntBetween } from '../common/utils.js';

// eslint-disable-next-line import/prefer-default-export
export const breakpointTest = () => {
  const targetDomain = `http://${fromEnv('TARGET_HOSTNAME')}:${fromEnv('TARGET_PORT')}`;
  const targetPath = fromEnv('TARGET_PATH') || "/";

  const uri = `${targetDomain}${targetPath}`;
  const tags = { targetDomain, targetPath };
  const params = { tags, timeout: '360s' }; // 6mins

  const res = http.get(uri, params);
  check(res,
    {
      'is status 200': (r) => r.status === 200,
    },
    tags
  );
  sleep(randomIntBetween(globalThis.PAUSE_MIN, globalThis.PAUSE_MAX));
};
