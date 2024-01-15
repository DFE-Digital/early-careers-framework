/* eslint-disable import/extensions, import/no-unresolved */

import { fromEnv } from "./common/utils.js";

export { apiSmokeTest } from './scripts/api-smoke-test.js';
export { getSuccessfulResponseFromWebPage } from './scripts/get-successful-response-from-web-page.js';
export { getSuccessfulResponseFromEndpoint } from './scripts/get-successful-response-from-endpoint.js';
export { smokeTest } from './scripts/smoke-test.js';

// eslint-disable-next-line no-undef
globalThis.PAUSE_MIN = Math.max(1 * (__ENV.PAUSE_MIN || 0), 0);
// eslint-disable-next-line no-undef
globalThis.PAUSE_MAX = Math.max(1 * (__ENV.PAUSE_MAX || 0), globalThis.PAUSE_MIN);

const defaultConfig = {
  insecureSkipTlsVerify: false, // set to true to ignore certificate errors (e.g. self-signed test certs)
};

const scenario = fromEnv('SCENARIO');
// eslint-disable-next-line no-restricted-globals
const testConfig = JSON.parse(open(`./options/${scenario}.json`));

// eslint-disable-next-line prefer-object-spread
export const options = Object.assign(
  defaultConfig,
  testConfig
);

export const run = () => {
  // eslint-disable-next-line no-console
  console.log('No scenarios in test.json. Executing default function...');
}

export const handleSummary = (data) => ({  [fromEnv('REPORT_FILE')]: JSON.stringify(data) });

export default run;
