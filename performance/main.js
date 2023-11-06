/* eslint-disable import/extensions, import/no-unresolved */

import { fromEnv } from './common/utils.js';

export { smokeTest } from './scenarios/smoke-test.js';
export { apiLoadTest } from './scenarios/api-load-test.js';

// eslint-disable-next-line no-undef
globalThis.PAUSE_MIN = Math.max(1 * (__ENV.PAUSE_MIN || 1), 1);
// eslint-disable-next-line no-undef
globalThis.PAUSE_MAX = Math.max(1 * (__ENV.PAUSE_MAX || 5), 1);

// load test config, used to populate exported options object:
// eslint-disable-next-line no-restricted-globals
const testConfig = JSON.parse(open('./config/test.json'));

const scenario = fromEnv('SCENARIO');
if (scenario) {
  if (Object.keys(testConfig.scenarios).indexOf(scenario) >= 0) {
    testConfig.scenarios = { [scenario]: testConfig.scenarios[scenario] };
  }
  else
  {
    delete testConfig.scenarios;
  }

  testConfig.thresholds = Object.keys(testConfig.thresholds).reduce((out, key) => {
    if (key.indexOf(`scenario:${scenario},`) >= 0 || key.indexOf(`scenario:${scenario}}`) >= 0) {
      // eslint-disable-next-line no-param-reassign
      out[key] = testConfig.thresholds[key];
    }

    return out;
  }, {});
}

// combine the above with options set directly:
// eslint-disable-next-line prefer-object-spread
export const options = Object.assign(
  {
    insecureSkipTlsVerify: false // set to true to ignore certificate errors (e.g. self-signed test certs)
  },
  testConfig
);

export const run = () => {
  // eslint-disable-next-line no-console
  console.log('No scenarios in test.json. Executing default function...');
}

export const handleSummary = (data) => ({  [fromEnv('REPORT_FILE')]: JSON.stringify(data) });

export default run;
