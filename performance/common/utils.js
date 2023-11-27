// load default environment variables
// eslint-disable-next-line no-restricted-globals
const defaultEnvironment = JSON.parse(open('../config/environment.json'));

export const randomIntBetween = (min = 1, max = 1) =>  // min and max included
  Math.floor(Math.random() * (max - min + 1) + min);

// eslint-disable-next-line no-undef
export const fromEnv = (key) => __ENV[`PERF_${key}`] || defaultEnvironment[key];
