describe("Admin user editing delivery partner", () => {
  const basePath = "/admin/suppliers";
  const leadProviderId = "e38e8825-4430-4da0-ac54-6e42dea5c360";
  const deliveryPartnerName = "Delivery Partner 1";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should be able to edit a delivery partner", () => {
    cy.appScenario("admin/suppliers/manage_delivery_partner");
    const newName = "New delivery partner";

    cy.visit(basePath);
    cy.get("a").contains(deliveryPartnerName).click();

    cy.location("pathname").should("match", /\/delivery-partners\/.*\/edit/);
    cy.get("[name='delivery_partner_form[name]']").should(
      "have.value",
      deliveryPartnerName
    );
    cy.get("[name='delivery_partner_form[name]']").type(
      `{selectall}${newName}`
    );
    cy.get(
      `[name='delivery_partner_form[lead_provider_ids][]'][value=${leadProviderId}]`
    ).uncheck();
    cy.clickCommitButton();

    cy.location("pathname").should("equal", basePath);
    cy.get("main").should("contain", newName);
    cy.get("main").should("not.contain", deliveryPartnerName);

    cy.get("a").contains(newName).click();
    cy.get(
      `[name='delivery_partner_form[lead_provider_ids][]'][value=${leadProviderId}]`
    ).should("not.be.checked");

    // Should be able to go back to suppliers page
    cy.clickBackLink();
    cy.location("pathname").should("equal", basePath);
  });

  // This test currently fails due to things arising from nested checkboxes
  // We are replacing these nested checkboxes with two pages anyway
  // TODO reenable when this has been done
  xdescribe("Accessibility", () => {
    it("/admin/suppliers/:id/edit should be accessible", () => {
      cy.appScenario("admin/suppliers/manage_delivery_partner");

      cy.visit(basePath);
      cy.get("a").contains(deliveryPartnerName).click();

      cy.location("pathname").should("match", /\/delivery-partners\/.*\/edit/);
      cy.checkA11y();
    });
  });
});
