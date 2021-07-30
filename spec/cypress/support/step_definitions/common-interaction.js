import { When, Then } from "cypress-cucumber-preprocessor/steps";

const inputs = {
  "email input": "input[name*=email]",
  "delivery partner name input": 'input[type="text"]',
  "name input": '[name*="name"]',
  "cookie consent radio": '[name="cookies_form[analytics_consent]"]',
  "location input": "#nomination-request-form-local-authority-id-field",
  "school input": "#nomination-request-form-school-id-field",
  "supplier name input": "#supplier-user-form-supplier-field",
  "search box": "input[name=query]",
  "replace induction tutor": "input[value=replace].govuk-radios__input",
  "update induction tutor": "input[value=update].govuk-radios__input",
  "new participant type radio": '[name="schools_add_participant_form[type]"]',
  "programme choice radio":
    '[name="schools_year2020_form[induction_programme_choice]"]',
  "cip radio": '[name="schools_year2020_form[induction_programme_choice]"]',
  "nominate induction tutor radio button":
    "input[value=yes].govuk-radios__input",
  "opt out of updates radio button": "input[value=no].govuk-radios__input",
  "nominate someone for updates radio button":
    "input[value=i_dont_know].govuk-radios__input",
  "design and deliver our own programme radio button":
    "input[value=design_our_own].govuk-radios__input",
  "no early career teachers radio button":
    "input[value=no_early_career_teachers].govuk-radios__input",
  "new participant mentor radio":
    '[name="schools_add_participant_form[mentor_id]"]',
  "decision note": '[name="profile_validation_decision[note]"]',
};

const buttons = {
  "create admin button": "[data-test=create-admin-button]",
  "delete button": "[data-test=delete-button]",
  "create delivery partner button":
    '.govuk-button:contains("new delivery partner")',
  "back button": '.govuk-button:contains("Back")',
  "create supplier user button": '.govuk-button:contains("Add a new user")',
  "search button": "[data-test=search-button]",
  "impersonate button": "[data-test=impersonate-button]",
  "stop impersonating button": "[data-test=stop-impersonating-button]",
  "remove button": ".govuk-button[value=Remove]",
};

const links = {
  link: "a",
  "edit admin link": "[data-test=edit-admin-link]",
  "change name link": 'a:contains("Change name")',
  "edit supplier user link": "[data-test=edit-supplier-user-link]",
  "change school link": "[data-test=change-school]",
};

const elements = {
  ...inputs,
  ...buttons,
  ...links,
  "page body": "main",
  "cookie banner": ".js-cookie-banner",
  "page title": "h1",
  "notification banner": "[data-test=notification-banner]",
  "autocomplete dropdown item": ".autocomplete__menu li",
  "success panel": "[data-test=success-panel]",
  "schools table": "[data-test=schools-table]",
};

const get = (element) => cy.get(elements[element] || element);

When("I set {string} to {string}", (element, value) => {
  get(element).get(`[value="${value}"]`).click();
});

When("I clear {string}", (element) => {
  get(element).clear();
});

When("I type {string} into {string}", (value, element) => {
  get(element).type(value);
});

When("I type {string} into field labelled {string}", (value, label) => {
  cy.get("label").contains(label).click();
  cy.focused().clear().type(value);
});

When("I press enter in {string}", (element) => {
  get(element).type(`{enter}`);
});

When("I click on {string}", (element) => {
  get(element).click();
});

When("I click on first {string}", (element) => {
  get(element).first().click();
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

When("I add a school urn csv to the file input", () => {
  cy.get("#partnership-csv-upload-csv-field").attachFile({
    filePath: "school_urns.csv",
    mimeType: "text/csv",
  });
});

When("I add a school urn csv with errors to the file input", () => {
  cy.get("#partnership-csv-upload-csv-field").attachFile({
    filePath: "school_urns_errors.csv",
    mimeType: "text/csv",
  });
});

When("I click on the delivery partner radio button", () => {
  cy.get('[type="radio"].govuk-radios__input').first().check();
});

Then("{string} should be unchecked", (element) => {
  get(element).should("not.be.checked");
});

Then("{string} with value {string} is checked", (element, value) => {
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

Then("{string} label should be unchecked", (text) => {
  cy.get("label")
    .contains(text)
    .invoke("attr", "for")
    .then((inputId) => {
      if (!inputId) {
        throw new Error("for not available on this label");
      }

      cy.get(`#${inputId}`).should("not.be.checked");
    });
});

Then("the table should have {int} row(s)", (number) => {
  cy.get("tbody").find("tr").should("have.length", number);
});
