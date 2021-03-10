describe("Admin user creating another admin user", () => {
  beforeEach(() => {
    cy.login("admin");
  });

  it("should show a create administrator button", () => {
    cy.visit("/admin/administrators");
    cy.get(".govuk-button").should("contain", "Create a new administrator");
  });

  it("should create a new user", () => {
    const fullName = "John Smith";
    const email = "j.smith@example.com";

    cy.visit("/admin/administrators");
    cy.get(".govuk-button").contains("Create a new administrator").click();

    cy.location("pathname").should("equal", "/admin/administrators/new");
    cy.get("input[name='user[full_name]']").type(fullName);
    cy.get("input[name='user[email]']").type(email);
    cy.get(".govuk-button").contains("Continue").click();

    cy.location("pathname").should(
      "equal",
      "/admin/administrators/new/confirm"
    );
    cy.get("main").should("contain", fullName);
    cy.get("main").should("contain", email);
    cy.get("input.govuk-button").contains("Create administrator user").click();

    cy.location("pathname").should("equal", "/admin/administrators");
    cy.get(".govuk-button").contains("View all administrators").click();

    cy.location("pathname").should("equal", "/admin/administrators");
    cy.get("main").should("contain", fullName);
    cy.get("main").should("contain", email);

    cy.appEval(`User.find_by(email: "${email}").admin?`).then((result) =>
      expect(result).to.equal(true)
    );
  });
});
