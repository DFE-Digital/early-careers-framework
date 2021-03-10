document.body.className = document.body.className
  ? `${document.body.className} js-enabled`
  : "js-enabled";

/* eslint-disable import/first */
require.context("govuk-frontend/govuk/assets");

import "../styles/application.scss";
import { initAll } from "govuk-frontend";
import "./admin/supplier-users";
import "./cookie-banner";

initAll();
