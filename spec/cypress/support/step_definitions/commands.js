import { Given } from "cypress-cucumber-preprocessor/steps";

Given("I am logged in as user with email {string}", (email) => {
  cy.loginWithEmail(email);
});
