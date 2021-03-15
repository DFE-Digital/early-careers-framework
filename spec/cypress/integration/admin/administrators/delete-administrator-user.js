describe("Admin user deleting another admin user", () => {
  const adminUserName = "Emma Dow";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should allow deleting user", () => {
    cy.appScenario("/admin/administrators/create_admin_user");
    cy.visit("/admin/administrators");
    cy.get("main").should("contain", adminUserName);
    cy.get("[data-cy=edit-admin-link]").contains(adminUserName).click();
    cy.get("[data-cy=delete-button]").click();
    cy.get("main").should("contain", "Do you want to delete this user?");
    cy.get("main").should("contain", "Admin user: Emma Dow");
    cy.get(".govuk-button--warning").click();
    cy.get("main").should("not.contain", adminUserName);
    cy.get("main").should("contain", "User deleted");
  });
});
