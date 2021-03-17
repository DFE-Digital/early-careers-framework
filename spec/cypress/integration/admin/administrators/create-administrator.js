describe("Admin user creating another admin user", () => {
  const basePath = "/admin/administrators";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should create a new user", () => {
    const fullName = "John Smith";
    const email = "j.smith@example.com";

    cy.visit(basePath);
    cy.get("[data-test=create-admin-button").click();

    cy.location("pathname").should("equal", `${basePath}/new`);
    cy.chooseNameAndEmailForUser(fullName, email);

    cy.location("pathname").should("equal", `${basePath}/new/confirm`);
    cy.get("main").should("contain", fullName);
    cy.get("main").should("contain", email);
    cy.get("input.govuk-button").contains("Create administrator user").click();

    cy.location("pathname").should("equal", basePath);
    cy.get("main").should("contain", fullName);
    cy.get("main").should("contain", email);
    cy.get("[data-test=notification-banner]").should("contain", "Success");
    cy.get("[data-test=notification-banner]").should("contain", "User added");
    cy.get("[data-test=notification-banner]").should(
      "contain",
      "They have been sent an email to sign in"
    );
  });

  describe("Accessibility", () => {
    it("/admin/administrators should be accessible", () => {
      cy.visit(basePath);
      cy.checkA11y();
    });

    it("/admin/administrators/new should be accessible", () => {
      cy.visit(`${basePath}/new`);
      cy.checkA11y();
    });

    it("/admin/administrators/new/confirm should be accessible", () => {
      const fullName = "John Smith";
      const email = "j.smith@example.com";

      cy.visit(`${basePath}/new`);
      cy.chooseNameAndEmailForUser(fullName, email);

      cy.location("pathname").should("equal", `${basePath}/new/confirm`);
      cy.checkA11y();
    });
  });
});
