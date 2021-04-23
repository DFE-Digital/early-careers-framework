import { Given, Then } from "cypress-cucumber-preprocessor/steps";

Given("seed data should be loaded", () => {
  cy.app("load_seed");
});

Then("the page should be accessible", () => {
  cy.checkA11y();
});

Then("percy should be sent snapshot", () => {
  cy.percySnapshot();
});

Then("percy should be sent snapshot called {string}", (name) => {
  cy.percySnapshot(name);
});
