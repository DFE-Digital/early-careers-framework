/* eslint-disable import/no-commonjs */
const { readFileSync, writeFileSync } = require("fs");

const inputPath = process.argv[2] || `./smoke-test.log`;
const outputPath = process.argv[3] || `./smoke-test-log.json`;

const data = readFileSync(inputPath, 'utf8');
const log = data.trim().split('\n').map(line => JSON.parse(line));

const serializedLog = JSON.stringify(log);
writeFileSync(outputPath, serializedLog, 'utf8');
