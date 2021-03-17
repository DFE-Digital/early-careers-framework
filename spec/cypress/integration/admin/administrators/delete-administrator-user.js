describe("Admin user deleting another admin user", () => {
  const adminUserName = "Emma Dow";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should allow deleting user", () => {
    cy.appScenario("admin/administrators/manage_admin_users");
    cy.visit("/admin/administrators");
    cy.get("main").should("contain", adminUserName);
    cy.get("[data-test=edit-admin-link]").contains(adminUserName).click();
    cy.get("[data-test=delete-button]").click();
    cy.get("main").should("contain", "Do you want to delete this user?");
    cy.get("main").should("contain", "Admin user: Emma Dow");
    cy.get(".data-test-delete-submit-button").click();
    cy.get("main").should("not.contain", adminUserName);
    cy.get("main").should("contain", "User deleted");
  });

  describe("Accessibility", () => {
    it("/admin/administrators/ should be accessible", () => {
      cy.appScenario("admin/administrators/manage_admin_users");

      cy.visit("/admin/administrators");
      cy.checkA11y();
    });

    it("/admin/administrators/:id/edit should be accessible", () => {
      cy.appScenario("admin/administrators/manage_admin_users");

      cy.visit("/admin/administrators");
      cy.get("[data-test=edit-admin-link]").contains(adminUserName).click();
      cy.checkA11y();
    });

    it("/admin/administrators/:id/delete should be accessible", () => {
      cy.appScenario("admin/administrators/manage_admin_users");

      cy.visit("/admin/administrators");
      cy.get("[data-test=edit-admin-link]").contains(adminUserName).click();

      cy.get("[data-test=delete-button]").click();
      cy.checkA11y();
    });
  });
});
