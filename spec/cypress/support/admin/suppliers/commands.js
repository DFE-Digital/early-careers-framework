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
