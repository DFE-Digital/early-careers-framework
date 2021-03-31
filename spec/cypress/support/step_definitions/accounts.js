import { Given } from "cypress-cucumber-preprocessor/steps";

Given("Following Factory set up was run {string}", (factoryName) => {
  cy.appFactories([["create", factoryName]]).as("factoryData");
});

Given(
  "Following Factory set up was run {string} with trait {string}",
  (factoryName, traitName) => {
    cy.appFactories([["create", factoryName, traitName]]).as("factoryData");
  }
);
