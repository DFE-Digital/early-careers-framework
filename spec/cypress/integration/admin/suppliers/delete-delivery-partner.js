describe("Admin user deleting delivery partner", () => {
  beforeEach(() => {
    cy.login("admin");
  });

  it("should create a new delivery partner", () => {
    cy.appScenario("admin/suppliers/manage_delivery_partner");

    cy.visit("/admin/suppliers");
    cy.appEval(`DeliveryPartner.first.name`).then((deliveryPartnerName) => {
      cy.get("a").contains(deliveryPartnerName).click();

      cy.location("pathname").should(
        "contain",
        "/admin/suppliers/delivery-partner"
      );
      cy.get(".govuk-button").contains("Delete").click();

      cy.location("pathname").should("contain", "/delete");
      cy.get("main").should("contain", deliveryPartnerName);
      cy.get(".govuk-button").contains("Delete").click();

      cy.location("pathname").should("equal", "/admin/suppliers");
      cy.get("main").should("not.contain", deliveryPartnerName);

      cy.appEval(
        `DeliveryPartner.find_by(name: "${deliveryPartnerName}").present?`
      ).then((result) => expect(result).to.equal(false));
      cy.appEval(
        `DeliveryPartner.with_discarded.find_by(name: "${deliveryPartnerName}").present?`
      ).then((result) => expect(result).to.equal(true));
    });
  });
});
