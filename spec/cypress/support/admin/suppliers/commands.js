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

Cypress.Commands.add("confirmCreateSupplierUser", () => {
  cy.get(".govuk-button").click();
});

Cypress.Commands.add("chooseLeadProviderName", () => {
  cy.appEval(`LeadProvider.first.name`).then((leadProviderName) => {
    cy.get("input[type=text]").type(leadProviderName);
    cy.get(".govuk-button").click();
  });
});

Cypress.Commands.add("chooseNameAndEmail", (name, email) => {
  cy.get("input[name='supplier_user_form[full_name]'").type(name);
  cy.get("input[name='supplier_user_form[email]'").type(email);
  cy.get(".govuk-button").click();
});
