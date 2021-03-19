import { When, Then } from "cypress-cucumber-preprocessor/steps";

const elements = {
  "cookie consent": '[name="cookies_form[analytics_consent]"]',
  "cookie banner": ".js-cookie-banner",
  "create admin button": "[data-test=create-admin-button]",
  main: "main",
  name: "input[name*=full_name]",
  email: "input[name*=email]",
  "notification banner": "[data-test=notification-banner]",
  "edit admin link": "[data-test=edit-admin-link]",
  "delete button": "[data-test=delete-button]",
  "create delivery partner button":
    '.govuk-button:contains("new delivery partner")',
  "delivery partner name": 'input[type="text"]',
  "change name link": 'a:contains("Change name")',
};

const get = (element) => cy.get(elements[element] || element);

When("I set {string} radio to {string}", (element, value) => {
  get(element).get(`[value="${value}"]`).click();
});

When("I type {string} into {string} field", (value, element) => {
  get(element).type(value);
});

When("I click on {string}", (element) => {
  get(element).click();
});

When("I click on {string} containing {string}", (element, containing) => {
  get(element).contains(containing).click();
});

When("I click on {string} label", (text) => {
  cy.get("label").contains(text).click();
});

When("I click the submit button", () => {
  cy.clickCommitButton();
});

When("I click the back link", () => {
  cy.clickBackLink();
});

Then("{string} radios should be unchecked", (element) => {
  get(element).should("not.be.checked");
});

Then("{string} radio with value {string} is checked", (element, value) => {
  get(element).get(`[value="${value}"]`).should("be.checked");
});

Then("{string} should have value {string}", (element, value) => {
  get(element).should("have.value", value);
});

Then("{string} should contain {string}", (element, value) => {
  get(element).should("contain", value);
});

Then("{string} should not contain {string}", (element, value) => {
  get(element).should("not.contain", value);
});

Then("{string} should be hidden", (element) => {
  get(element).should("not.be.visible");
});

Then("{string} should not exist", (element) => {
  get(element).should("not.exist");
});

Then("{string} label should be checked", (text) => {
  cy.get("label")
    .contains(text)
    .invoke("attr", "for")
    .then((inputId) => {
      if (!inputId) {
        throw new Error("for not available on this label");
      }

      cy.get(`#${inputId}`).should("be.checked");
    });
});

Then("the page should be accessible", () => {
  cy.checkA11y();
});
