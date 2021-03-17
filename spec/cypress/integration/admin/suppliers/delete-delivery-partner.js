describe("Admin user deleting delivery partner", () => {
  const basePath = "/admin/suppliers";
  const deliveryPartnerName = "Delivery Partner 1";

  beforeEach(() => {
    cy.login("admin");

    cy.appScenario("admin/suppliers/manage_delivery_partner");

    cy.visit(basePath);
    cy.get("a").contains(deliveryPartnerName).click();

    cy.location("pathname").should("contain", `${basePath}/delivery-partner`);
    cy.get(".govuk-button").contains("Delete").click();

    cy.location("pathname").should("match", /\/delivery-partners\/.*\/delete/);
    cy.get("main").should("contain", deliveryPartnerName);
  });

  it("should delete a new delivery partner", () => {
    cy.get(".govuk-button").contains("Delete").click();

    cy.location("pathname").should("equal", basePath);
    cy.get("main").should("not.contain", deliveryPartnerName);
  });

  it("has a back button to the edit page", () => {
    cy.get(".govuk-button").contains("Back").click();
    cy.location("pathname").should("match", /\/delivery-partners\/.*\/edit/);
    cy.get("main").should("contain", deliveryPartnerName);
  });
});
