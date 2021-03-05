describe("Admin user creating another admin user", () => {
  beforeEach(() => {
    cy.login("admin");
  });

  it("should show a create administrator button", () => {
    cy.visit("/admin/administrators");
    cy.get("a.govuk-button").contains("Create a new administrator");
  });

  it("should create a new user", () => {
    const fullName = "John Smith";
    const email = "j.smith@example.com";

    cy.visit("/admin/administrators");
    cy.get("a.govuk-button").contains("Create a new administrator").click();

    cy.get("h1").should("contain", "Create a new administrator user");
    cy.get("input[name='user[full_name]']").type(fullName);
    cy.get("input[name='user[email]']").type(email);
    cy.get("input.govuk-button").contains("Continue").click();

    cy.get("h1").should("contain", "Confirm these details");
    cy.contains(fullName);
    cy.contains(email);
    cy.get("input.govuk-button").contains("Create administrator user").click();

    cy.get("h1.govuk-panel__title").contains("Administrator created");
    cy.get("a.govuk-button").contains("View all administrators").click();

    cy.get("h1").contains("Administrators");
    cy.contains(fullName);
    cy.contains(email);

    cy.appEval(`User.find_by(email: "${email}").admin?`).then((result) =>
      expect(result).to.equal(true)
    );
  });
});
