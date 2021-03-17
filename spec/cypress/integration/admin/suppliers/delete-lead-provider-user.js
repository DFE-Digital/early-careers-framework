describe("Admin user deleting lead provider user", () => {
  const leadProviderUserName = "John Wick";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should allow deleting user", () => {
    cy.appScenario("/admin/suppliers/create_lead_provider_user");
    cy.visit("/admin/suppliers");
    cy.get("a").contains("All users").click();
    cy.get("main").should("contain", leadProviderUserName);
    cy.get("[data-test=edit-supplier-user-link]")
      .contains(leadProviderUserName)
      .click();
    cy.get("[data-test=delete-button]").click();
    cy.get("main").should("contain", "Do you want to delete this user?");
    cy.get("main").should("contain", "Supplier user: John Wick");
    cy.get(".data-test-delete-submit-button").click();
    cy.get("main").should("not.contain", leadProviderUserName);
    cy.get("main").should("contain", "User deleted");
  });

  describe("Accessibility", () => {
    it("/admin/suppliers/lead-providers/users/:id/edit should be accessible", () => {
      cy.appScenario("/admin/suppliers/create_lead_provider_user");

      cy.visit("/admin/suppliers/users");
      cy.get("[data-test=edit-supplier-user-link]")
        .contains(leadProviderUserName)
        .click();

      cy.location("pathname").should(
        "match",
        /\/admin\/suppliers\/lead-providers\/users\/.*\/edit/
      );
      cy.checkA11y();
    });

    it("/admin/suppliers/lead-providers/users/:id/delete should be accessible", () => {
      cy.appScenario("/admin/suppliers/create_lead_provider_user");

      cy.visit("/admin/suppliers/users");
      cy.get("[data-test=edit-supplier-user-link]")
        .contains(leadProviderUserName)
        .click();

      cy.get("[data-test=delete-button]").click();

      cy.location("pathname").should(
        "match",
        /\/admin\/suppliers\/lead-providers\/users\/.*\/delete/
      );
      cy.checkA11y();
    });
  });
});
