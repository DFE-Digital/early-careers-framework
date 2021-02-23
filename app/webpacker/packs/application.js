/* eslint-disable import/first */
require.context("govuk-frontend/govuk/assets");

import "../styles/application.scss";
import { initAll } from "govuk-frontend";
import "./admin/supplier-users";
import "./school_search";
import "./autocomplete/school_autocomplete";
import "./autocomplete/local_authority_autocomplete";
import "./autocomplete/location_autocomplete";
import "./autocomplete/network_autocomplete";
import "whatwg-fetch";

initAll();
