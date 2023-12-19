/* eslint-disable import/no-commonjs */
const { readFileSync, writeFileSync } = require("fs");

const reportFolder = process.argv[2] || './reports';
const scenario = process.argv[3] || 'smoke-test';

const logPath = `${reportFolder}/${scenario}.log`;
const outputPath = `${reportFolder}/${scenario}-log.json`;

console.log(`Loading k6 log file (${logPath})`);
const data = readFileSync(logPath, 'utf8');

console.log(`Serialising k6 log`);
const log = data.trim().split('\n').map(line => JSON.parse(line));

console.log(`Writing k6 JSON log file (${outputPath})`);
const serializedLog = JSON.stringify(log, null, 2);
writeFileSync(outputPath, serializedLog, 'utf8');
