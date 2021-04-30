import "@percy/cypress";
import OnRails from "./on-rails";
import "cypress-file-upload";

// Heads up, this is NOT used in the Cucumber specs - see factory-bot.js

Cypress.Commands.add("loginCreated", (factory) => {
  cy.visit(
    `/users/confirm_sign_in?login_token=${
      OnRails.getCreatedRecord(factory).login_token
    }`
  );
  cy.get('[action="/users/sign_in_with_token"] [name="commit"]').click();
});

Cypress.Commands.add("login", (...traits) => {
  cy.appFactories([["create", "user", ...traits]])
    .as("userData")
    .then(([user]) => {
      cy.visit(`/users/confirm_sign_in?login_token=${user.login_token}`);
    });

  cy.get('[action="/users/sign_in_with_token"] [name="commit"]').click();
});

Cypress.Commands.add("logout", () => {
  cy.get("#navigation").contains("Logout").click();

  cy.location("pathname").should("eq", "/");
});

Cypress.Commands.add("clickBackLink", () => {
  cy.get(".govuk-back-link").click();
});

Cypress.Commands.add("clickCommitButton", () => {
  cy.get("[name=commit]").click();
});

export const SIGN_IN_EMAIL_TEMPLATE = "7ab8db5b-9842-4bc3-8dbb-f590a3198d9e";
export const ADMIN_ACCOUNT_CREATED_TEMPLATE =
  "3620d073-d2cc-4d65-9a51-e12770cf25d9";
export const NOMINATION_EMAIL_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f";
export const NOMINATION_CONFIRMATION_EMAIL_TEMPLATE =
  "240c5685-5cb0-40a9-9bd4-1a595d991cbc";

export const computeHeadersFromEmail = (email) =>
  email.header.reduce(
    (hashSoFar, element) => ({
      ...hashSoFar,
      [element.name]: element.unparsed_value,
    }),
    {}
  );
Cypress.Commands.add("appSentEmails", () =>
  cy.appEval("ActionMailer::Base.deliveries")
);

Cypress.Commands.add("verifySignInEmailSentToUser", (user) => {
  cy.appSentEmails().then((emails) => {
    expect(emails).to.have.lengthOf(1);
    const headersHash = computeHeadersFromEmail(emails[0]);
    expect(headersHash["template-id"]).to.eq(SIGN_IN_EMAIL_TEMPLATE);
    expect(headersHash.personalisation.full_name).to.eq(user.full_name);
    expect(headersHash.To).to.eq(user.email);
  });
});

Cypress.Commands.add("chooseNameAndEmailForUser", (name, email) => {
  cy.get("input[name*=full_name").type(name);
  cy.get("input[name*=email").type(email);
  cy.clickCommitButton();
});

Cypress.Commands.add("titleShouldEqual", (title) => {
  cy.title().should(
    "equal",
    `${title} - Manage training for early career teachers`
  );
});
