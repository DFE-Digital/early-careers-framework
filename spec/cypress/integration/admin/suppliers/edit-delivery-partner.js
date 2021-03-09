describe("Admin user editing delivery partner", () => {
  beforeEach(() => {
    cy.login("admin");
  });

  it("should create a new delivery partner", () => {
    cy.appScenario("admin/suppliers/manage_delivery_partner");
    const newName = "New delivery partner";

    cy.visit("/admin/suppliers");
    cy.appEval(`DeliveryPartner.first.name`).then((deliveryPartnerName) => {
      cy.get("a").contains(deliveryPartnerName).click();

      cy.location("pathname").should(
        "contain",
        "/admin/suppliers/delivery-partner"
      );
      cy.get(".govuk-button").contains("Edit").click();

      cy.location("pathname").should("contain", "/edit");
      cy.get("[name='delivery_partner_form[name]']").should(
        "have.value",
        deliveryPartnerName
      );
      cy.get("[name='delivery_partner_form[name]']").type(
        `{selectall}${newName}`
      );
      cy.get(".govuk-button").click();

      cy.location("pathname").should(
        "contain",
        "/admin/suppliers/delivery-partner"
      );
      cy.get("main").should("contain", newName);
      cy.get("main").should("not.contain", deliveryPartnerName);
      cy.appEval(
        `DeliveryPartner.find_by(name: "${newName}").present?`
      ).then((result) => expect(result).to.equal(true));
      cy.appEval(
        `DeliveryPartner.find_by(name: "${deliveryPartnerName}").present?`
      ).then((result) => expect(result).to.equal(false));
    });
  });

  it("removes a lead provider when unchecked", () => {
    cy.appScenario("admin/suppliers/manage_delivery_partner");

    cy.visit("/admin/suppliers");
    cy.appEval(`DeliveryPartner.first.name`).then((deliveryPartnerName) => {
      cy.get("a").contains(deliveryPartnerName).click();

      cy.get(".govuk-button").contains("Edit").click();

      cy.appEval(`LeadProvider.first.id`).then((leadProviderId) => {
        cy.get(
          `[name='delivery_partner_form[lead_providers][]'][value=${leadProviderId}]`
        ).uncheck();
        cy.get(".govuk-button").click();

        cy.appEval(`LeadProvider.find("${leadProviderId}")`).then(
          (leadProviderName) => {
            cy.get("main").should("not.contain", leadProviderName);
          }
        );
      });
    });
  });
});
