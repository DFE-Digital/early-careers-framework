/* eslint-disable import/first */
require.context("govuk-frontend/govuk/assets");

//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/all_components

import "../styles/application.scss";
import { initAll } from "govuk-frontend";

initAll();
