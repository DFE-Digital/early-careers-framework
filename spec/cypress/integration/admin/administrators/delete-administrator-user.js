describe("Admin user deleting another admin user", () => {
  const adminUserName = "Emma Dow";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should allow deleting user", () => {
    cy.appScenario("/admin/administrators/create_admin_user");
    cy.visit("/admin/administrators");
    cy.get("main").should("contain", adminUserName);
    cy.get(".cypress-test-edit-admin-link").contains(adminUserName).click();
    cy.get(".cypress-test-delete-button").click();
    cy.get(".cypress-test-delete-button").click();
    cy.get("main").should("not.contain", adminUserName);
    cy.get("main").should("contain", "User deleted");
  });
});
