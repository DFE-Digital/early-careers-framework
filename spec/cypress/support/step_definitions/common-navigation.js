import { Given, When, Then } from "cypress-cucumber-preprocessor/steps";

Given("I am logged in as a {string}", (user) => cy.login(user));
Given("I am logged in as an {string}", (user) => cy.login(user));

Given("scenario {string} has been ran", (scenario) => cy.appScenario(scenario));

const pagePaths = {
  cookie: "/cookies",
  start: "/",
  "admin listing": "/admin/administrators",
  "admin creation": "/admin/administrators/new",
  "admin confirm creation": "/admin/administrators/new/confirm",
  "delivery partner listing": "/admin/suppliers",
  "choose new delivery partner name":
    "/admin/suppliers/new/delivery-partner/choose-name",
  "choose new delivery partner lead providers":
    "/admin/suppliers/new/delivery-partner/choose-lps",
  "new delivery partner review": "/admin/suppliers/new/delivery-partner/review",
  "delivery partner edit": /\/delivery-partners\/.*\/edit/,
};

Given("I am on {string} page", (page) => {
  const path = pagePaths[page];
  cy.visit(path);
});

Given("I am on {string} page without JavaScript", (page) => {
  const path = pagePaths[page];
  cy.visit(`${path}?nojs=nojs`);
});

When("I navigate to {string} page", (page) => {
  const path = pagePaths[page];
  cy.visit(path);
});

Then("I should be on {string} page", (page) => {
  const path = pagePaths[page];

  if (!path) {
    throw new Error(`Path not found for ${page}`);
  }

  if (typeof path === "string") {
    cy.location("pathname").should("equal", path);
  } else {
    cy.location("pathname").should("match", path);
  }
});
