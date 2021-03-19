import { When, Then } from "cypress-cucumber-preprocessor/steps";

When("I click to accept cookies", () => {
  cy.get(".js-cookie-form").contains("Accept").click();
});

When("I click to reject cookies", () => {
  cy.get(".js-cookie-form").contains("Reject").click();
});

When("I hide cookie banner", () => {
  cy.get(".js-cookie-banner").contains("Hide this message").click();
});

Then("cookie preferences have changed", () => {
  cy.contains("You’ve set your cookie preferences.");
});
