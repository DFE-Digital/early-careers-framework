/* eslint-disable import/first */
require.context("govuk-frontend/govuk/assets");

document.body.className = document.body.className
  ? `${document.body.className} js-enabled`
  : "js-enabled";

// Styling
import "../styles/application.scss";

// External dependencies
import { initAll } from "govuk-frontend";
import "whatwg-fetch";

// Project JS
import "./admin/supplier-users";
import "./components/step-by-step-nav";
import "./cookie-banner";
import "./school_search";
import "./nominations";

initAll();
