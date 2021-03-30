import { Given } from "cypress-cucumber-preprocessor/steps";

Given("Following Factory set up was run {string}", (factoryString) => {
  cy.appFactories([factoryString.split(" ")]).as("factoryData");
});
