/* eslint-disable import/first */
require.context("govuk-frontend/govuk/assets");

import "../styles/application.scss";
import { initAll } from "govuk-frontend";
import "./admin/supplier-users";

initAll();
