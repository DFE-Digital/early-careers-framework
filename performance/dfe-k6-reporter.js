/* eslint-disable import/no-commonjs,no-case-declarations */
const { readdirSync , readFileSync, writeFileSync, unlinkSync } = require('node:fs');
const util = require('node:util');
const path = require('node:path');
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

// eslint-disable-next-line no-console
const logInfo = (...params) => console.log(...params);
// eslint-disable-next-line no-console
const logError = (...params) => console.error(...params);

const getVersionedFilename = (folder, search, ext) => {
  const filenames = readdirSync(folder);
  const filename = filenames.filter(foundFilename => foundFilename.startsWith(search) && foundFilename.endsWith(ext))[0];
  return path.join(folder, filename);
};

const getStyle = () => {
  const filepath = getVersionedFilename("../public/assets", "application", ".css");
  return readFileSync(filepath, "utf8");
};

const getScript = () => {
  const filepath = getVersionedFilename("../public/assets", "application", ".js");
  return readFileSync(filepath, "utf8");
};

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
  { text: metricName.replace('{', ' '), classes: "govuk-body-s" },
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
  if (stderr) logError('stderr:', stderr);
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
  const values = data.log.map(entry => entry.value);
  const sortedValues = [...values].sort((a, b) => a - b);
  let firstFail;

  const log = timeline
    .reduce((previous, timestamp) => {
      let value;

      switch (data.type) {
        case 'counter':
        // case 'rate':
          // sum the values for the period
          value = data.log
            .filter(entry => entry.timestamp === timestamp)
            .reduce((current, entry) => current + entry.value, 0);
          break;
        case 'rate':
          // sum the values for the period
          value = {
            checks: 0,
            passes: 0,
            fails: 0
          };

          data.log
            .filter(entry => entry.timestamp === timestamp)
            .forEach(entry => {
              value.checks += 1;

              if (entry.value === 1) {
                // eslint-disable-next-line no-param-reassign
                value.passes += 1;
              } else {
                // eslint-disable-next-line no-param-reassign
                value.fails -= 1;
                if (!firstFail) firstFail = timestamp;
              }
            });
          break;
        case 'gauge':
        case 'trend':
          // find the highest value for the period
          value = data.log
            .filter(entry => entry.timestamp === timestamp)
            .reduce((current, entry) => entry.value > current ? entry.value : current, 0);
          break;
        default:
          throw new Error(`Metric type of "${data.type}" not recognised`);
      }

      return { ...previous, [timestamp]: { timestamp, value } };
    }, {});

  const countedValues = values.filter(value => value > 0);
  const minimum = Math.min(...sortedValues);
  const maximum = Math.max(...sortedValues);
  const totalValues = values.length;

  // const timelineValues = timeline.map(timestamp => log[timestamp].value || 0);
  const timelineValues = timeline.map(timestamp => {
    if (typeof log[timestamp].value === "object") {
      return log[timestamp].value.checks || 0;
    }

    return log[timestamp].value || 0;
  });

  const timelineMinimum = Math.min(...timelineValues);
  const timelineMaximum = Math.max(...timelineValues);
  const yPadding = timelineMaximum * 0.1;

  switch (data.type) {
    case 'counter':
      return {
        values: {
          count: values.reduce((total, value) => total + value, 0),
          rate: timeline.reduce((total, timestamp) => total + log[timestamp].value, 0) / timeline.length,
        },
        config: {
          title: `${data.name} ${data.type}`,
          theme: 'base',
          xAxis: ["Time elapsed", 0, timelineValues.length],
          yAxis: ["Total per second", (timelineMinimum < 0 ? timelineMinimum : 0) - yPadding, timelineMaximum + yPadding],
          lines: [
            timelineValues,
          ],
        },
        log,
      };
    case 'rate':
      const ratePasses = timeline.map(timestamp => log[timestamp].value.passes || 0);
      const rateFails = timeline.map(timestamp => log[timestamp].value.fails || 0);

      const rateMinimum = Math.min(...rateFails);
      const rateMaximum = Math.max(...ratePasses);
      const rateYPadding = rateMaximum * 0.1;

      return {
        values: {
          rate: values.reduce((total, value) => total + value, 0) / totalValues,
          passes: values.filter(value => value === 1).length,
          fails: values.filter(value => value === 0).length,
          firstFail,
        },
        config: {
          title: `${data.name} ${data.type}`,
          theme: 'base',
          xAxis: ["Time elapsed", 0, timelineValues.length],
          yAxis: ["Total per second", (rateMinimum < 0 ? rateMinimum : 0) - rateYPadding, rateMaximum + rateYPadding],
          lines: [
            ratePasses,
            rateFails,
          ],
        },
        log,
      };
    case 'trend':
      return {
        values: {
          "p(90)": sortedValues[Math.ceil(totalValues * 0.90) - 1],
          "p(95)": sortedValues[Math.ceil(totalValues * 0.95) - 1],
          avg: values.reduce((total, value) => total + value, 0) / totalValues,
          min: minimum,
          med: (sortedValues[Math.floor(totalValues / 2)] + sortedValues[Math.ceil(totalValues / 2)]) / 2,
          max: maximum
        },
        config: {
          title: `${data.name} ${data.type}`,
          theme: 'base',
          xAxis: ["Time elapsed", 0, timelineValues.length],
          yAxis: ["Total per second", (timelineMinimum < 0 ? timelineMinimum : 0) - yPadding, timelineMaximum + yPadding],
          lines: [
            timelineValues,
          ],
        },
        log,
      };
    case 'gauge':
      return {
        values: {
          value: countedValues[totalValues - 1],
          min: Math.min(...countedValues),
          max: Math.max(...countedValues)
        },
        config: {
          title: `${data.name} ${data.type}`,
          theme: 'base',
          xAxis: ["Time elapsed", 0, timelineValues.length],
          yAxis: ["Total per second", (timelineMinimum < 0 ? timelineMinimum : 0) - yPadding, timelineMaximum + yPadding],
          lines: [
            timelineValues,
          ],
        },
        log,
      };
    default:
      throw new Error(`Metric type of "${data.type}" not recognised`);
  }
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

    logError(entry);
  });

  for (let i = 0; i < chartNames.length; i += 1) {
    const chartName = chartNames[i];
    const chartData = charts[chartName];
    const chart = processChart(chartData, timeline);

    chart.name = chartName;
    chart.markdown = mermaidConfigToText(chart.config);
    // eslint-disable-next-line no-await-in-loop
    chart.svg = await mermaidTextToSvg(chart.markdown);

    out[chartName] = chart;
  }

  return out;
}

const defaultJsonReport = {
  metrics: {
    vus: { values: { min: 1, max: 1 } },
    http_reqs: { values: { count: 0, rate: 0 } },
    data_received: { values: { count: 0, rate: 0 } },
    data_sent: { values: { count: 0, rate: 0 } },
  }
}

const collateThresholdMetrics = (metrics) => {
  let totalFailures = 0
  let totalThresholds = 0

  Object.keys(metrics).forEach(metricName => {
    if (metrics[metricName].thresholds) {
      totalThresholds += 1
      const { thresholds } = metrics[metricName];

      Object.keys(thresholds).forEach(thresholdName => {
        if (thresholds[thresholdName].ok) return;
        totalFailures += 1
      });
    }
  });

  const totalPasses = totalThresholds - totalFailures;

  return [totalFailures, totalPasses, totalThresholds];
};

const collateCheckMetrics = (root) => {
// Count the checks and those that have passed or failed
// NOTE. Nested groups are not checked!
  let totalFailures = 0
  let totalPasses = 0
  if (root.checks) {
    const { passes, fails } = countChecks(root.checks)

    totalFailures += fails
    totalPasses += passes
  }

  root.groups.forEach(group => {
    if (!group.checks) return;

    const { passes, fails } = countChecks(group.checks);

    totalFailures += fails;
    totalPasses += passes;
  });

  const totalChecks = totalFailures + totalPasses;

  return [totalFailures, totalPasses, totalChecks];
};

const sumeriseGroupReport = async (group, logEntries) => {
  const charts = await generateCharts(logEntries, group.path);
  const chartNames = Object.keys(charts);

  // Count the thresholds and those that have failed
  const [thresholdFailures, , thresholdCount] = collateThresholdMetrics(charts);
  const [checkFailures, checkPasses] = collateCheckMetrics(group);

  // assign charts to correct metrics
  const metrics = {}
  chartNames.forEach(metricName => {
    const metric = charts[metricName];

    // eslint-disable-next-line no-param-reassign
    metrics[metricName] = {
      ...metric,
      tableRow: metricTableRow(metricName, metric),
    };
  });

  const standardMetricRows = standardMetricKeys
    .filter(metricName => metrics[metricName])
    .map(metricName => metrics[metricName].tableRow);

  const otherMetricRows = otherMetricKeys
    .filter(metricName => metrics[metricName])
    .map(metricName => metrics[metricName].tableRow);

  const customMetricsKeys = Object.keys(metrics)
    .filter(metricName => !(standardMetricKeys.includes(metricName) || otherMetricKeys.includes(metricName)))
    .sort();
  const customMetricRows = customMetricsKeys
    .map(metricName => metrics[metricName].tableRow);

  const breachedMetrics = {}
  const breachedMetricsKeys = Object.keys(metrics)
    .filter(metricName => metrics[metricName].threshold !== undefined)
    .sort();
  breachedMetricsKeys
    .forEach(metricName => {
      const { thresholds } = charts[metricName];

      Object.keys(thresholds).forEach(threshold => {
        const [metric, tagString] = metricName.replace('}', '').split('{');
        const tags = (tagString || '').split(',')
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

  return {
    metrics,
    standardMetricRows,
    otherMetricRows,
    customMetricRows,

    breachedMetrics,

    thresholdFailures,
    thresholdCount,
    checkFailures,
    checkPasses,
  };
};

const summariseReport = async (rootGroup, logEntries) => {
  const groupReport = await sumeriseGroupReport(rootGroup, logEntries);

  return {
    rootGroup: {
      ...rootGroup,
      ...groupReport,
    },
  };
};

(async () => {
  logInfo(`Loading JSON report (${reportPath})`);
  // eslint-disable-next-line import/no-unresolved
  const jsonReportSrc = readFileSync(reportPath, "utf8");
  const jsonReport = Object.assign(defaultJsonReport, JSON.parse(jsonReportSrc));

  logInfo(`Loading JSON log (${logPath})`);
  // eslint-disable-next-line import/no-unresolved
  const jsonLogSrc = readFileSync(logPath, "utf8");
  const jsonLog = JSON.parse(jsonLogSrc);

  logInfo(`Generating JSON context for reports`);
  const report = await summariseReport(jsonReport.root_group, jsonLog);
  const style = getStyle();
  const script = getScript();
  const ctx = {
    title: "Performance summary",
    themeColor: "#003a69",
    assetPath: "https://design-system.service.gov.uk/assets",
    assetUrl: "https://design-system.service.gov.uk/assets",
    service: { name: "Continuing Professional Development" },
    report,
    style,
    script,
  };
  const serializedCtx = JSON.stringify(ctx, null, 2);
  writeFileSync(`${reportFolder}/${scenario}-ctx.json`, serializedCtx, "utf8");

  logInfo(`Generating HTML report (${outputPath})`);
  const htmlReport = nunjucks.render('report.njk', ctx);
  writeFileSync(outputPath, htmlReport, "utf8");

  logInfo(`Generating Markdown summary (${summaryPath})`);
  const markdownSummary = nunjucks.render('summary.njk', ctx);
  writeFileSync(summaryPath, markdownSummary, "utf8");
})();
