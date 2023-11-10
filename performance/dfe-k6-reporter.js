const { readFileSync, writeFileSync } = require("fs");
const nunjucks = require("nunjucks");

const scriptPath = process.argv[1].replace('/dfe-k6-reporter.js', '');
const inputPath = process.argv[2] || `./smoke-test-summary.json`;
const outputPath = process.argv[3] || `./smoke-test-summary.html`;
const markdownSummaryPath = process.argv[4] || `./smoke-test-summary.md`;

const standardMetricKeys = [
  'grpc_req_duration',
  'http_req_duration',
  'http_req_waiting',
  'http_req_connecting',
  'http_req_tls_handshaking',
  'http_req_sending',
  'http_req_receiving',
  'http_req_blocked',
  'iteration_duration',
  'group_duration',
  'ws_connecting',
  'ws_msgs_received',
  'ws_msgs_sent',
  'ws_sessions',
];

const otherMetricKeys = [
  'iterations',
  'data_sent',
  'checks',
  'http_reqs',
  'data_received',
  'vus_max',
  'vus',
  'http_req_failed',
  'http_req_duration{expected_response:true}',
];

const checkFailed = (metric, valName) => {
  let status = '';

  if (!metric.thresholds) return status;

  Object.keys(metric.thresholds)
    .forEach(threshold => {
      if (!threshold.includes(valName)) return;
      status = metric.thresholds[threshold].ok ? 'good' : 'failed';
    });

  return status;
};

const metricTableRow = (metricName, metric) => [
    { text: metricName, classes: "govuk-body-s" },
    { text: metric.values.count ? metric.values.count : "-", format: "numeric", classes: `govuk-body-s ${checkFailed(metric, "count")}` },
    { text: metric.values.rate ? metric.values.rate.toFixed(2) : "-", format: "numeric", classes: `govuk-body-s ${checkFailed(metric, "rate")}` },
    { text: metric.values.avg ? metric.values.avg.toFixed(2) : "-", format: "numeric", classes: `govuk-body-s ${checkFailed(metric, "avg")}` },
    { text: metric.values.max ? metric.values.max.toFixed(2) : "-", format: "numeric", classes: `govuk-body-s ${checkFailed(metric, "max")}` },
    { text: metric.values.med ? metric.values.med.toFixed(2) : "-", format: "numeric", classes: `govuk-body-s ${checkFailed(metric, "med")}` },
    { text: metric.values.min ? metric.values.min.toFixed(2) : "-", format: "numeric", classes: `govuk-body-s ${checkFailed(metric, "min")}` },
    { text: metric.values['p(90)'] ? metric.values['p(90)'].toFixed(2) : "-", format: "numeric", classes: `govuk-body-s ${checkFailed(metric, "p(90)")}` },
    { text: metric.values['p(95)'] ? metric.values['p(95)'].toFixed(2) : "-", format: "numeric", classes: `govuk-body-s ${checkFailed(metric, "p(95)")}` }
  ];

const countChecks = (checks) => {
  let passes = 0;
  let fails = 0;

  checks.forEach(check => {
    passes += parseInt(check.passes, 10);
    fails += parseInt(check.fails, 10);
  });

  return { passes, fails };
}

const summariseReport = (data) => {
  data.metrics.vus = data.metrics.vus || { values: { min: 1, max: 1 } };
  data.metrics.http_reqs = data.metrics.http_reqs || { values: { count: 0, rate: 0 } };
  data.metrics.data_received = data.metrics.data_received || { values: { count: 0, rate: 0 } };
  data.metrics.data_sent = data.metrics.data_sent || { values: { count: 0, rate: 0 } };

  // Count the thresholds and those that have failed
  let thresholdFailures = 0
  let thresholdCount = 0

  Object.keys(data.metrics).forEach(metricName => {
    if (data.metrics[metricName].thresholds) {
      thresholdCount += 1
      const { thresholds } = data.metrics[metricName];

      Object.keys(thresholds).forEach(thresholdName => {
        if (thresholds[thresholdName].ok) return;
        thresholdFailures += 1
      });
    }
  });

  // Count the checks and those that have passed or failed
  // NOTE. Nested groups are not checked!
  let checkFailures = 0
  let checkPasses = 0
  if (data.root_group.checks) {
    const { passes, fails } = countChecks(data.root_group.checks)

    checkFailures += fails
    checkPasses += passes
  }

  data.root_group.groups.forEach(group => {
    if (!group.checks) return;

    const { passes, fails } = countChecks(group.checks);

    checkFailures += fails;
    checkPasses += passes;
  });

  const standardMetrics = {};
  standardMetricKeys.forEach(metricName => {
    if (!data.metrics[metricName]) return;
    standardMetrics[metricName] = data.metrics[metricName];
  });

  const standardMetricRows = Object.keys(standardMetrics)
    .map(metricName => metricTableRow(metricName, standardMetrics[metricName]));

  const otherMetrics = {};
  otherMetricKeys.forEach(metricName => {
    if (!data.metrics[metricName]) return;
    otherMetrics[metricName] = data.metrics[metricName];
  });

  const otherMetricRows = Object.keys(otherMetrics)
    .map(metricName => metricTableRow(metricName, otherMetrics[metricName]));

  const sortedMetrics = {};
  const sortedMetricsKeys = Object.keys(data.metrics).filter(metricName => !(standardMetricKeys.includes(metricName) || otherMetricKeys.includes(metricName))).sort();
  sortedMetricsKeys.forEach(metricName => {
    sortedMetrics[metricName] = data.metrics[metricName];
  });

  const sortedMetricRows = Object.keys(sortedMetrics)
    .map(metricName => metricTableRow(metricName, sortedMetrics[metricName]));

  return {
    data,
    standardMetricRows,
    otherMetricRows,
    sortedMetricRows,

    thresholdFailures,
    thresholdCount,
    checkFailures,
    checkPasses,
  };
};

nunjucks.configure(
  [
    `${scriptPath}/views`,
    `${scriptPath}/../node_modules/govuk-frontend/`,
  ],
  {
    autoescape: true,
  }
);

// eslint-disable-next-line import/no-unresolved
const jsonSrc = readFileSync(inputPath, "utf8");
const jsonReport = JSON.parse(jsonSrc);
const jsonSummary = summariseReport(jsonReport);

const htmlReport = nunjucks.render('report.njk', {
  themeColor: "#003a69",
  assetPath: "https://design-system.service.gov.uk/assets",
  assetUrl: "https://design-system.service.gov.uk/assets",
  service: { name: "Continuing Professional Development" },
  report: {
    name: "Performance summary",
    summary: jsonSummary,
  },
});

// eslint-disable-next-line no-multi-str
const markdownSummaryReport = nunjucks.render('summary.njk', jsonSummary);

writeFileSync(outputPath, htmlReport, "utf8");
writeFileSync(markdownSummaryPath, markdownSummaryReport, "utf8");
