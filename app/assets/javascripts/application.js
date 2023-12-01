/* eslint-disable import/first */
require.context("govuk-frontend/dist/govuk/assets");

document.body.className += ' js-enabled' + ('noModule' in HTMLScriptElement.prototype ? ' govuk-frontend-supported' : '');

// External dependencies
import "es6-promise/auto";
import "whatwg-fetch";

import * as GOVUKFrontend from "govuk-frontend";

// Project JS
import "./admin/supplier-users";
import "./cookie-banner";
import "./nominations";
import "./autocomplete";

window.GOVUKFrontend = GOVUKFrontend;

window.onload = function init() {
  window.GOVUKFrontend.initAll();
};
