Cypress.Commands.add("clickCreateSupplierButton", () => {
  cy.get(".govuk-button").contains("Add a new supplier").click();
});

Cypress.Commands.add("chooseSupplierName", (deliveryPartnerName) => {
  cy.get("input[type=text]").type(deliveryPartnerName);
  cy.clickCommitButton();
});

Cypress.Commands.add("chooseDeliveryPartnerType", () => {
  cy.get("[type=radio]").check("delivery_partner");
  cy.clickCommitButton();
});

Cypress.Commands.add("chooseLeadProviderType", () => {
  cy.get("[type=radio]").check("lead_provider");
  cy.clickCommitButton();
});

Cypress.Commands.add("chooseFirstLeadProviderAndCohort", () => {
  cy.get(
    "[name='delivery_partner_form[lead_providers][]'][type=checkbox]"
  ).check();
  cy.get(
    "[name='delivery_partner_form[provider_relationship_hashes][]'][type=checkbox]"
  ).check();
  cy.clickCommitButton();
});

Cypress.Commands.add("chooseFirstCIPForLeadProvider", () => {
  cy.get("input[name='lead_provider_form[cip]'][type=radio]").check();
  cy.clickCommitButton();
});

Cypress.Commands.add("chooseFirstCohortForLeadProvider", () => {
  cy.get("input[name='lead_provider_form[cohorts][]'][type=checkbox]").check();
  cy.clickCommitButton();
});

Cypress.Commands.add("confirmCreateSupplier", () => {
  cy.clickCommitButton();
});

Cypress.Commands.add("clickCreateSupplierUserButton", () => {
  cy.get(".govuk-button").contains("Add a new user").click();
});

Cypress.Commands.add("confirmCreateSupplierUser", () => {
  cy.clickCommitButton();
});

Cypress.Commands.add("chooseLeadProviderName", () => {
  cy.appEval(`LeadProvider.first.name`).then((leadProviderName) => {
    cy.get("input[type=text]").type(leadProviderName);
    cy.clickCommitButton();
  });
});

Cypress.Commands.add("chooseNameAndEmailForLeadProviderUser", (name, email) => {
  cy.get("input[name='supplier_user_form[full_name]'").type(name);
  cy.get("input[name='supplier_user_form[email]'").type(email);
  cy.clickCommitButton();
});
