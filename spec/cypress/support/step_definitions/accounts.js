import { Given, And } from "cypress-cucumber-preprocessor/steps";

Given("Admin account was created with {string}", (emailString) => {
  cy.appFactories([["create", "user", "admin", { email: emailString }]]).as(
    "userData"
  );
});

Given("Lead Provider account was created with {string}", (emailString) => {
  cy.appFactories([
    ["create", "user", "lead_provider", { email: emailString }],
  ]).as("userData");
});

Given(
  "Induction Coordinator account was created with {string}",
  (emailString) => {
    cy.appFactories([
      ["create", "user", "induction_coordinator", { email: emailString }],
    ]).as("userData");
  }
);

And("I sign in", () => {
  cy.get('[action="/users/sign_in_with_token"] [name="commit"]').click();
});
