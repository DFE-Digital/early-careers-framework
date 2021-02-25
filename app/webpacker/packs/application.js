/* eslint-disable import/first */
require.context("govuk-frontend/govuk/assets");

import "core-js";
import "../styles/application.scss";
import { initAll } from "govuk-frontend";
import "./admin/supplier-users";
import "./school_search";
import "./autocomplete";
import "whatwg-fetch";

initAll();
