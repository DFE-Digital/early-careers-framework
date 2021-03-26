import { Given, When, Then } from "cypress-cucumber-preprocessor/steps";

Given("I am logged in as a {string}", (user) => cy.login(user));
Given("I am logged in as an {string}", (user) => cy.login(user));

Given("scenario {string} has been run", (scenario) => cy.appScenario(scenario));

const pagePaths = {
  cookie: "/cookies",
  start: "/",
  "admin index": "/admin/administrators",
  "admin creation": "/admin/administrators/new",
  "admin confirm creation": "/admin/administrators/new/confirm",
  "delivery partner index": "/admin/suppliers",
  "choose new delivery partner name":
    "/admin/suppliers/new/delivery-partner/choose-name",
  "choose new delivery partner lead providers":
    "/admin/suppliers/new/delivery-partner/choose-lps",
  "choose delivery partner cohorts":
    "/admin/suppliers/new/delivery-partner/choose-cohorts",
  "new delivery partner review": "/admin/suppliers/new/delivery-partner/review",
  "delivery partner edit": /\/delivery-partners\/.*\/edit/,
  "delivery partner delete": /\/delivery-partners\/.*\/delete/,
  "users sign in": "/users/sign_in",
  "lead provider users index": "/admin/suppliers/users",
  "new lead provider user": "/admin/suppliers/users/new",
  "new lead provider user details": "/admin/suppliers/users/new/user-details",
  "new lead provider user review": "/admin/suppliers/users/new/review",
  "lead provider user delete": /\/lead-providers\/users\/.*\/delete/,
  "choose programme": "/schools/choose-programme",
  schools: "/schools",
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
