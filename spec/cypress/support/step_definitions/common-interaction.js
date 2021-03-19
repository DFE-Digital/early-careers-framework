import { When, Then } from "cypress-cucumber-preprocessor/steps";

const elements = {
  "cookie consent": '[name="cookies_form[analytics_consent]"]',
  "cookie banner": ".js-cookie-banner",
};

When("I set {string} radio to {string}", (element, value) => {
  const selector = elements[element];
  cy.get(selector).get(`[value="${value}"]`).click();
});

When("I click the submit button", () => {
  cy.clickCommitButton();
});

Then("{string} radios should be unchecked", (element) => {
  const selector = elements[element];
  cy.get(selector).should("not.be.checked");
});

Then("{string} radio with value {string} is checked", (element, value) => {
  const selector = elements[element];
  cy.get(selector).get(`[value="${value}"]`).should("be.checked");
});

Then("{string} should contain {string}", (element, value) => {
  const selector = elements[element];
  cy.get(selector).should("contain", value);
});

Then("{string} should be hidden", (element) => {
  const selector = elements[element];
  cy.get(selector).should("not.be.visible");
});

Then("{string} should not exist", (element) => {
  const selector = elements[element];
  cy.get(selector).should("not.exist");
});
