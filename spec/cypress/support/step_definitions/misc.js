import { Then } from "cypress-cucumber-preprocessor/steps";

Then("the page should be accessible", () => {
  cy.checkA11y();
});

Then("the Swagger documentation should be visible", () => {
  cy.get("section.models").should("be.visible");
});
