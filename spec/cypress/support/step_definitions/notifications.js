import { Given, When } from "cypress-cucumber-preprocessor/steps";

Given(
  "An email sign in notification should be sent for email {string}",
  (email) => {
    cy.verifySignInEmailSentForEmail(email);
  }
);

Given(
  "An Admin account created email will be sent to the email {string}",
  (email) => {
    cy.verifyAdminAccountCreatedEmailSentForEmail(email);
  }
);

When(
  "I should be able to login with magic link for email {string}",
  (email) => {
    cy.signInUsingEmailUrl(email);
  }
);
