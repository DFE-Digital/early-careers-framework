describe("Admin user deleting delivery partner user", () => {
  const deliveryPartnerName = "John Wick";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should allow deleting user", () => {
    cy.appScenario("/admin/suppliers/create_lead_provider_user");
    cy.visit("/admin/suppliers");
    cy.get("a").contains('All users').click()
    cy.get("main").should("contain", deliveryPartnerName);
    cy.get('.cypress-test-edit-supplier-user-link').contains(deliveryPartnerName).click();
    cy.get('.cypress-test-delete-button').click()
    cy.get('.cypress-test-delete-button').click()
    cy.get("main").should("not.contain", deliveryPartnerName);
    cy.get("main").should("contain", 'User deleted');
  });
});
