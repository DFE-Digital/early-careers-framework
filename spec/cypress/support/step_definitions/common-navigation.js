import { Given, When, Then } from "cypress-cucumber-preprocessor/steps";

Given("scenario {string} has been ran", (scenario) => cy.appScenario(scenario));

const pagePaths = {
  cookie: "/cookies",
  start: "/",
  dashboard: "/dashboard",
  "edit username": "/username/edit",
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

const assertOnPage = (page) => {
  const path = pagePaths[page];

  if (!path) {
    throw new Error(`Path not found for ${page}`);
  }

  if (typeof path === "string") {
    cy.location("pathname").should("equal", path);
  } else {
    cy.location("pathname").should("match", path);
  }
};

Then("I should be on {string} page", (page) => {
  assertOnPage(page);
});

Then("I should have been redirected to {string} page", (page) => {
  assertOnPage(page);
});
