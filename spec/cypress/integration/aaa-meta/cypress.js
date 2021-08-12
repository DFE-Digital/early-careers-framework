/**
 * !!!!!
 *
 * This file name starts with aaa so that it runs before all the other tests
 * which rely on the functionality being tested in this file.
 *
 * Please don't rename it!
 */
describe("Meta test helper tests", () => {
  it("should have login and logout helper commands", () => {
    cy.login();
    cy.get("h1").should("contain", "You cannot use this service yet");

    cy.logout();
    cy.get("h1").should("contain", "You're now signed out");

    cy.login("admin");
    cy.get("h1").should("contain", "Schools");
  });

  it("should have factory_bot helper functions", () => {
    cy.appFactories([["create", "lead_provider"]]).as("leadProvider");

    cy.login("admin");

    cy.visit("/admin/suppliers");

    cy.get("@leadProvider").should(([provider]) => {
      expect(provider.name).to.equal("Lead Provider");
    });

    // @todo this test needs fleshing out when there's more functionality
    cy.get("[data-test=supplier-name]").contains("Lead Provider");
  });

  it("should have a cleanable database", () => {
    cy.appFactories([
      ["create", "lead_provider"],
      ["create", "lead_provider"],
      ["create", "lead_provider"],
    ]);

    cy.login("admin");
    cy.visit("/admin/suppliers");

    cy.get('[data-test=supplier-name]:contains("Lead Provider")').should(
      "have.length",
      3
    );

    cy.app("clean");

    cy.login("admin");

    cy.get('.govuk-link:contains("Lead Provider")').should("have.length", 0);
  });

  it("should start with a clean database", () => {
    cy.login("admin");

    cy.get('.govuk-link:contains("Lead Provider")').should("have.length", 0);
  });
});
