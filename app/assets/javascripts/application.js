/* eslint-disable import/first */
require.context("govuk-frontend/govuk/assets");

document.body.className = document.body.className
  ? `${document.body.className} js-enabled`
  : "js-enabled";

// External dependencies
import "es6-promise/auto";
import "whatwg-fetch";

import * as GOVUKFrontend from 'govuk-frontend'

// Project JS
import "./admin/supplier-users";
import "./components/step-by-step-nav";
import "./cookie-banner";
import "./nominations";
import "./autocomplete";

window.GOVUKFrontend = GOVUKFrontend

window.onload = function () {
  window.GOVUKFrontend.initAll()
}

