// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

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

const SIGN_IN_EMAIL_TEMPLATE = "7ab8db5b-9842-4bc3-8dbb-f590a3198d9e";
const EMAIL_CONFIRMATION_TEMPLATE = "50059d26-c65d-4e88-831a-8bfb9f4116cd";
const PRIMARY_CONTACT_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f";

const computeHeadersFromEmail = (email) =>
  email.header.reduce(
    (hashSoFar, element) => ({
      ...hashSoFar,
      [element.name]: element.unparsed_value,
    }),
    {}
  );

Cypress.Commands.add("verifySignInEmailSent", (user) => {
  cy.appEval("ActionMailer::Base.deliveries").then((emails) => {
    expect(emails).to.have.lengthOf(1);
    const headersHash = computeHeadersFromEmail(emails[0]);
    expect(headersHash["template-id"]).to.eq(SIGN_IN_EMAIL_TEMPLATE);
    expect(headersHash.personalisation.full_name).to.eq(user.full_name);
    expect(headersHash.To).to.eq(user.email);
  });
});

Cypress.Commands.add("verifyConfirmationEmailSent", (user) => {
  cy.appEval("ActionMailer::Base.deliveries").then((emails) => {
    expect(emails).to.have.lengthOf(1);
    const headersHash = computeHeadersFromEmail(emails[0]);
    expect(headersHash["template-id"]).to.eq(EMAIL_CONFIRMATION_TEMPLATE);
    expect(headersHash.personalisation.full_name).to.eq(user.full_name);
    expect(headersHash.To).to.eq(user.email);
  });
});

Cypress.Commands.add("verifyPrimaryContactEmailSent", (coordinator, email) => {
  cy.appEval("ActionMailer::Base.deliveries").then((emails) => {
    expect(emails).to.have.lengthOf(1);
    const headersHash = computeHeadersFromEmail(emails[0]);
    expect(headersHash["template-id"]).to.eq(PRIMARY_CONTACT_TEMPLATE);
    expect(headersHash.personalisation.full_name).to.eq(coordinator.full_name);
    expect(headersHash.personalisation.email).to.eq(coordinator.email);
    expect(headersHash.To).to.eq(email);
  });
});
