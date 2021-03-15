describe("Admin user deleting delivery partner user", () => {
  const deliveryPartnerName = "John Wick";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should allow deleting user", () => {
    cy.appScenario("/admin/suppliers/create_lead_provider_user");
    cy.visit("/admin/suppliers");
    cy.get("a").contains("All users").click();
    cy.get("main").should("contain", deliveryPartnerName);
    cy.get("[data-cy=edit-supplier-user-link]")
      .contains(deliveryPartnerName)
      .click();
    cy.get("[data-cy=delete-button]").click();
    cy.get("main").should("contain", "Do you want to delete this user?");
    cy.get("main").should("contain", "Supplier user: John Wick");
    cy.get(".govuk-button--warning").click();
    cy.get("main").should("not.contain", deliveryPartnerName);
    cy.get("main").should("contain", "User deleted");
  });
});
