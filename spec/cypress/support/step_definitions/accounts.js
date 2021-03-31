import { Given } from "cypress-cucumber-preprocessor/steps";

Given("Following Factory set up was run {string}", (factoryString) => {
  const factoryArray = [[factoryString.split(" ")]].flat;
  cy.appFactories(factoryArray).as("factoryData");
});

Given(
  "Following Factory set up was run {string} with trait {string}",
  (factoryName, traitName) => {
    // cy.appFactories(factoryArray).as("factoryData");
    cy.appFactories([["create", factoryName, traitName]]).as("factoryData");
  }
);
