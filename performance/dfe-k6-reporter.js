/* eslint-disable import/no-commonjs */
const { readFileSync, writeFileSync, unlinkSync } = require('node:fs');
const util = require('node:util');
const exec = util.promisify(require('node:child_process').exec);
const nunjucks = require("nunjucks");

const scriptPath = process.argv[1].replace('/dfe-k6-reporter.js', '');
const reportFolder = process.argv[2] || './reports';
const scenario = process.argv[3] || 'smoke-test';

const reportPath = `${reportFolder}/${scenario}-report.json`;
const logPath = `${reportFolder}/${scenario}-log.json`;
const outputPath = reportPath.replace('.json', '.html');
const summaryPath = reportPath.replace('-report.json', '-summary.md');

nunjucks.configure(
  [
    `${scriptPath}/views`,
    `${scriptPath}/../node_modules/govuk-frontend/`,
  ],
  {
    autoescape: true,
  }
);

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

const chartTextPath = './chart.md';
const chartImagePath = './chart.svg';
const chartActualImagePath = './chart-1.svg';
const mermaidTextToSvg = async (input) => {
  writeFileSync(chartTextPath, input, 'utf8');

  // eslint-disable-next-line no-await-in-loop
  const { stderr } = await exec(`../node_modules/.bin/mmdc -i ${chartTextPath} -o ${chartImagePath} --theme neutral`);
  if (stderr) console.error('stderr:', stderr);
  const svg = readFileSync(chartActualImagePath, 'utf8');

  unlinkSync(chartActualImagePath);
  unlinkSync(chartTextPath);

  return svg;
}

const mermaidConfigToText = (config) => [
  "```mermaid",
  `---
config:
  theme: base
  themeVariables:
    xyChart:
      backgroundColor: "#FFFFFF"
      titleColor: "#0B0B0C"
      xAxisLabelColor: "#0B0B0C"
      xAxisTitleColor: "#0B0B0C"
      xAxisTickColor: "#B1B4B6"
      xAxisLineColor: "#B1B4B6"
      yAxisLabelColor: "#0B0B0C"
      yAxisTitleColor: "#0B0B0C"
      yAxisTickColor: "#B1B4B6"
      yAxisLineColor: "#B1B4B6"
      plotColorPalette: "#1D70B8"
--- `,
  "xychart-beta",
  `  title "${config.title}"`,
  `  x-axis "${config.xAxis[0]}" ${config.xAxis[1]} --> ${config.xAxis[2]}`,
  `  y-axis "${config.yAxis[0]}" ${config.yAxis[1]} --> ${config.yAxis[2]}`,
  ...config.lines.map(line => `  line [${line.join(', ')}]`),
  "```",
  ""
].join('\n');

const processChart = (data, timeline) => {
  let minimum;
  let maximum;
  let total = 0;

  const log = timeline.reduce((previous, timestamp) => {
    let value = 0;

    switch (data.type) {
      case 'counter':
      case 'rate':
        // sum the values for the period
        value = data.log.reduce((current, entry) =>
          entry.timestamp === timestamp ? current + entry.value : current,
        0);
        break;
      default:
        // find the highest value for the period
        value = data.log.reduce((current, entry) =>
          entry.timestamp === timestamp && entry.value > current ? entry.value : current,
        0);
    }

    total += value;
    if (!maximum || value > maximum) maximum = value;
    if (!minimum || value < minimum) minimum = value;
    return { ...previous, [timestamp]: { timestamp, value } };
  }, {});

  const average = parseInt(`${total / timeline.length}`, 10);
  const median = parseInt(minimum + ((maximum - minimum) / 2), 10);

  const yPadding = (maximum * 0.1);
  const config = {
    title: `${data.name} ${data.type}`,
    theme: 'base',
    xAxis: ["Time elapsed", 0, timeline.length],
    yAxis: ["Total per second", (minimum < 0 ? minimum : 0) - yPadding, maximum + yPadding],
    lines: [
      timeline.map(timestamp => log[timestamp].value),
    ],
  }

  return {
    total,
    minimum,
    maximum,
    average,
    median,

    config,
    log,
  };
};

const generateCharts = async (log) => {
  const timeline = [];
  const chartNames = [];
  const charts = {};
  const out = {};

  log.forEach(entry => {
    const chartName = entry.metric;

    if (entry.type === "Point") {
      const timestamp = new Date(Date.parse(entry.data.time)).toTimeString().split(' ')[0];

      if (timeline.indexOf(timestamp) < 0) timeline.push(timestamp);
      if (chartNames.indexOf(chartName) < 0) chartNames.push(chartName);

      charts[chartName].log.push({ ...entry.data, timestamp });
      return;
    }

    if (entry.type === 'Metric') {
      charts[chartName] = { ...entry.data, name: chartName, log: [] };
      return;
    }

    console.error(entry);
  });

  for (let i = 0; i < chartNames.length; i += 1) {
    const chartName = chartNames[i];
    const chart = processChart(charts[chartName], timeline);

    chart.markdown = mermaidConfigToText(chart.config);
    // eslint-disable-next-line no-await-in-loop
    chart.svg = await mermaidTextToSvg(chart.markdown);

    out[chartName] = chart;
  }

  return out;
}

const summariseReport = (report, charts) => {
  // eslint-disable-next-line no-param-reassign
  report.metrics.vus = report.metrics.vus || { values: { min: 1, max: 1 } };
  // eslint-disable-next-line no-param-reassign
  report.metrics.http_reqs = report.metrics.http_reqs || { values: { count: 0, rate: 0 } };
  // eslint-disable-next-line no-param-reassign
  report.metrics.data_received = report.metrics.data_received || { values: { count: 0, rate: 0 } };
  // eslint-disable-next-line no-param-reassign
  report.metrics.data_sent = report.metrics.data_sent || { values: { count: 0, rate: 0 } };

  // Count the thresholds and those that have failed
  let thresholdFailures = 0
  let thresholdCount = 0

  Object.keys(report.metrics).forEach(metricName => {
    if (report.metrics[metricName].thresholds) {
      thresholdCount += 1
      const { thresholds } = report.metrics[metricName];

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
  if (report.root_group.checks) {
    const { passes, fails } = countChecks(report.root_group.checks)

    checkFailures += fails
    checkPasses += passes
  }

  report.root_group.groups.forEach(group => {
    if (!group.checks) return;

    const { passes, fails } = countChecks(group.checks);

    checkFailures += fails;
    checkPasses += passes;
  });

  const standardMetrics = {};
  standardMetricKeys.forEach(metricName => {
    if (!report.metrics[metricName]) return;
    standardMetrics[metricName] = report.metrics[metricName];
  });

  const standardMetricRows = Object.keys(standardMetrics)
    .map(metricName => metricTableRow(metricName, standardMetrics[metricName]));

  const otherMetrics = {};
  otherMetricKeys.forEach(metricName => {
    if (!report.metrics[metricName]) return;
    otherMetrics[metricName] = report.metrics[metricName];
  });

  const otherMetricRows = Object.keys(otherMetrics)
    .map(metricName => metricTableRow(metricName, otherMetrics[metricName]));

  const sortedMetrics = {};
  const sortedMetricsKeys = Object.keys(report.metrics).filter(metricName => !(standardMetricKeys.includes(metricName) || otherMetricKeys.includes(metricName))).sort();
  sortedMetricsKeys.forEach(metricName => {
    sortedMetrics[metricName] = report.metrics[metricName];
  });

  const sortedMetricRows = Object.keys(sortedMetrics)
    .map(metricName => metricTableRow(metricName, sortedMetrics[metricName]));

  const breachedMetrics = {}
  Object.keys(report.metrics).forEach(metricName => {
    const { thresholds } = report.metrics[metricName];

    if (!thresholds) return;

    Object.keys(thresholds).forEach(threshold => {
      const [metric, tagString] = metricName.replace('}', '').split('{');
      const tags = tagString.split(',')
          .reduce((out, tag) => {
            const index = tag.indexOf(':');
            const key = tag.substring(0, index);
            // eslint-disable-next-line no-param-reassign
            out[key] = tag.substring(index + 1);
            return out;
          }, {});

      if (!thresholds[threshold].ok) {
        breachedMetrics[tags.group] = breachedMetrics[tags.group] || [];
        breachedMetrics[tags.group].push({ threshold, metric });
      }
    });
  });

  Object.keys(report.metrics).forEach(metricName => {
    // eslint-disable-next-line no-param-reassign
    report.metrics[metricName] = { ...report.metrics[metricName], ...charts[metricName] };
  });

  return {
    data: report,
    standardMetricRows,
    otherMetricRows,
    sortedMetricRows,

    breachedMetrics,

    thresholdFailures,
    thresholdCount,
    checkFailures,
    checkPasses,
  };
};

(async () => {
  console.log(`Loading JSON report (${reportPath})`);
  // eslint-disable-next-line import/no-unresolved
  const jsonReportSrc = readFileSync(reportPath, "utf8");
  const jsonReport = JSON.parse(jsonReportSrc);

  console.log(`Loading JSON log (${logPath})`);
  // eslint-disable-next-line import/no-unresolved
  const jsonLogSrc = readFileSync(logPath, "utf8");
  const jsonLog = JSON.parse(jsonLogSrc);

  console.log(`Generating metric charts`);
  const charts = await generateCharts(jsonLog);

  console.log(`Generating JSON summary of report`);
  const jsonSummary = summariseReport(jsonReport, charts);

  console.log(`Generating HTML report (${outputPath})`);
  const style = readFileSync('./public/main.css', 'utf8');
  const script = readFileSync('./public/application.js', 'utf8');
  const ctx = {
    themeColor: "#003a69",
    assetPath: "https://design-system.service.gov.uk/assets",
    assetUrl: "https://design-system.service.gov.uk/assets",
    service: { name: "Continuing Professional Development" },
    report: {
      name: "Performance summary",
      summary: jsonSummary,
    },
    style,
    script,
  };
  // const serializedCtx = JSON.stringify(ctx, null, 2);
  // writeFileSync(`${reportFolder}/${scenario}-ctx.json`, serializedCtx, "utf8");
  const htmlReport = nunjucks.render('report.njk', ctx);
  writeFileSync(outputPath, htmlReport, "utf8");

  console.log(`Generating Markdown summary (${summaryPath})`);
  const markdownSummary = nunjucks.render('summary.njk', jsonSummary);
  writeFileSync(summaryPath, markdownSummary, "utf8");
})();
