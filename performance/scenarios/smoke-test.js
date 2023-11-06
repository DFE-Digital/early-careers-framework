/* eslint-disable import/extensions, import/no-unresolved */

import http from 'k6/http';
import { sleep } from 'k6';

import {fromEnv, randomIntBetween} from '../common/utils.js';

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
  paths.forEach(path => {
    const uri = `http://${fromEnv('TARGET_HOSTNAME')}:${fromEnv('TARGET_PORT')}${path}`;

    http.get(uri);

    sleep(randomIntBetween(globalThis.PAUSE_MIN, globalThis.PAUSE_MAX));
  });
};
