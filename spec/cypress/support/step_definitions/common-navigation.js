import { Given, When, Then } from "cypress-cucumber-preprocessor/steps";

Given("I am logged in as a {string}", (user) => cy.login(user));
Given("I am logged in as an {string}", (user) => cy.login(user));

Given("scenario {string} has been ran", (scenario) => cy.appScenario(scenario));

const pagePaths = {
  cookie: "/cookies",
  start: "/",
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
  cy.location("pathname").should("equal", path);
});
