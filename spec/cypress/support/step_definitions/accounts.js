import { Given } from "cypress-cucumber-preprocessor/steps";

Given("Admin account was created with {string}", (emailString) => {
  cy.appFactories([["create", "user", "admin", { email: emailString }]]).as(
    "userData"
  );
});

Given(
  "Admin account was created with email {string} and name {string}",
  (emailString, nameString) => {
    cy.appFactories([
      [
        "create",
        "user",
        "admin",
        { email: emailString, full_name: nameString },
      ],
    ]).as("userData");
  }
);

Given("Lead Provider account was created with {string}", (emailString) => {
  cy.appFactories([
    ["create", "user", "lead_provider", { email: emailString }],
  ]).as("userData");
});

Given(
  "Induction Coordinator account was created with {string}",
  (emailString) => {
    cy.appFactories([
      [
        "create",
        "user",
        "induction_coordinator_with_school",
        { email: emailString },
      ],
    ]).as("userData");
  }
);
