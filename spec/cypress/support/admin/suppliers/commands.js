Cypress.Commands.add("logout", () => {
  cy.get("#navigation").contains("Logout").click();

  cy.location("pathname").should("eq", "/");
});

Cypress.Commands.add("chooseSupplierName", (deliveryPartnerName) => {
  cy.get("input[type=text]").type(deliveryPartnerName);
  cy.get(".govuk-button").click();
});

Cypress.Commands.add("chooseDeliveryPartnerType", () => {
  cy.get("[type=radio]").check("delivery_partner");
  cy.get(".govuk-button").click();
});

Cypress.Commands.add("chooseLeadProviderType", () => {
  cy.get("[type=radio]").check("lead_provider");
  cy.get(".govuk-button").click();
});

Cypress.Commands.add("chooseFirstLeadProviderAndCohort", () => {
  cy.get(
    "[name='delivery_partner_form[lead_providers][]'][type=checkbox]"
  ).check();
  cy.get(
    "[name='delivery_partner_form[provider_relationship_hashes][]'][type=checkbox]"
  ).check();
  cy.get(".govuk-button").click();
});

Cypress.Commands.add("chooseFirstCIP", () => {
  cy.get("input[name='lead_provider_form[cip]'][type=radio]").check();
  cy.get(".govuk-button").click();
});

Cypress.Commands.add("chooseFirstCohort", () => {
  cy.get("input[name='lead_provider_form[cohorts][]'][type=checkbox]").check();
  cy.get(".govuk-button").click();
});

Cypress.Commands.add("confirmCreateSupplier", () => {
  cy.get(".govuk-button").click();
});
