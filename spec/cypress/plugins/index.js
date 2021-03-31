/// <reference types="cypress" />
// ***********************************************************
// This example plugins/index.js can be used to load plugins
//
// You can change the location of this file or turn off loading
// the plugins file with the 'pluginsFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/plugins-guide
// ***********************************************************

// This function is called when a project is opened or re-opened (e.g. due to
// the project's config changing)

const fs = require("fs");
const path = require("path");
const cucumber = require("cypress-cucumber-preprocessor").default;
const diff = require("fast-array-diff");

/* eslint-disable no-console */

/**
 * @type {Cypress.PluginConfig}
 */
module.exports = (on) => {
  on("file:preprocessor", cucumber());

  const accessiblePaths = [];
  const ID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g;

  on("task", {
    axe(accessiblePath) {
      accessiblePaths.push(accessiblePath.replace(ID_REGEX, ":id"));

      return null;
    },
  });

  // This will horrifically break if parallelisation is ever introduced 😬
  on("after:run", () => {
    accessiblePaths.sort();

    const filePath = path.resolve(
      __dirname,
      "../support/accessible-paths.json"
    );

    if (process.env.CI) {
      const testPaths = JSON.parse(fs.readFileSync(filePath, "utf8"));

      const result = diff.diff(testPaths, accessiblePaths);

      if (result.added.length || result.removed.length) {
        console.error(JSON.stringify(result, null, 2));
        throw new Error(
          "Accessible paths do not match, run `yarn cypress:run` locally to update."
        );
      } else {
        console.log("Accessible paths match.");
      }
    } else {
      const pathsString = JSON.stringify(accessiblePaths, null, 2);
      fs.writeFileSync(filePath, pathsString);
      console.log("Written accessible paths to file.");
    }
  });
};
