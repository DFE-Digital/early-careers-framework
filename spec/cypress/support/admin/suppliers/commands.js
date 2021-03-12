Cypress.Commands.add("clickCreateDeliveryPartnerButton", () => {
  cy.get(".govuk-button").contains("Add a new delivery partner").click();
});

Cypress.Commands.add("chooseSupplierName", (deliveryPartnerName) => {
  cy.get("input[type=text]").type(deliveryPartnerName);
  cy.clickCommitButton();
});

Cypress.Commands.add("chooseFirstLeadProviderAndCohort", () => {
  cy.get(
    "[name='delivery_partner_form[lead_provider_ids][]'][type=checkbox]"
  ).check();
  cy.get(
    "[name='delivery_partner_form[provider_relationship_hashes][]'][type=checkbox]"
  ).check();
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

Cypress.Commands.add("chooseLeadProviderName", (leadProviderName) => {
  cy.get("input[type=text]").type(leadProviderName);
  cy.clickCommitButton();
});

Cypress.Commands.add("chooseNameAndEmailForLeadProviderUser", (name, email) => {
  cy.get("input[name='supplier_user_form[full_name]'").type(name);
  cy.get("input[name='supplier_user_form[email]'").type(email);
  cy.clickCommitButton();
});
