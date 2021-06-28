import * as Sentry from "@sentry/browser";
import { Integrations } from "@sentry/tracing";

const release = document.querySelector('meta[name="release"]').content;
const dsn = document.querySelector('meta[name="sentry-dsn"]').content;

Sentry.init({
  dsn,
  release,
  integrations: [new Integrations.BrowserTracing()],

  // Set tracesSampleRate to 1.0 to capture 100%
  // of transactions for performance monitoring.
  // We recommend adjusting this value in production
  tracesSampleRate: 0.1,
});
