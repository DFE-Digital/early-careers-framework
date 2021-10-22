import { Then } from "cypress-cucumber-preprocessor/steps";

Then("the page should be accessible", () => {
  cy.checkA11y();
});

Then("percy should be sent snapshot", () => {
  cy.percySnapshot();
});

Then("percy should be sent snapshot called {string}", (name) => {
  cy.percySnapshot(name);
});

Then("the Swagger documentation should be visible", () => {
  cy.get("section.models").should("be.visible");
});
