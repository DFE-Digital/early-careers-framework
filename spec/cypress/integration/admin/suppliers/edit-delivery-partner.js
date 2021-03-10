describe("Admin user editing delivery partner", () => {
  const leadProviderName = "Lead Provider 1";
  const leadProviderId = "e38e8825-4430-4da0-ac54-6e42dea5c360";
  const deliveryPartnerName = "Delivery Partner 1";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should update a delivery partner", () => {
    cy.appScenario("admin/suppliers/manage_delivery_partner");
    const newName = "New delivery partner";

    cy.visit("/admin/suppliers");
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
    cy.clickCommitButton();

    cy.location("pathname").should(
      "contain",
      "/admin/suppliers/delivery-partner"
    );
    cy.get("main").should("contain", newName);
    cy.get("main").should("not.contain", deliveryPartnerName);
  });

  it("removes a lead provider when unchecked", () => {
    cy.appScenario("admin/suppliers/manage_delivery_partner");

    cy.visit("/admin/suppliers");

    cy.get("a").contains(deliveryPartnerName).click();

    cy.get(".govuk-button").contains("Edit").click();

    cy.get(
      `[name='delivery_partner_form[lead_provider_ids][]'][value=${leadProviderId}]`
    ).uncheck();
    cy.clickCommitButton();

    cy.get("main").should("not.contain", leadProviderName);
  });
});
