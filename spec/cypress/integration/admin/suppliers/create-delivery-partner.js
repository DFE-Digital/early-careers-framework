describe("Admin user creating delivery partner", () => {
  const basePath = "/admin/suppliers";
  const leadProviderName = "Lead Provider 1";
  const cohortName = "2021";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should create a new delivery partner", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const deliveryPartnerName = "New delivery partner";

    cy.visit(basePath);
    cy.clickCreateDeliveryPartnerButton();

    const newPartnerPath = `${basePath}/new/delivery-partner`;

    cy.location("pathname").should("equal", `${newPartnerPath}/choose-name`);
    cy.chooseSupplierName(deliveryPartnerName);

    cy.location("pathname").should("equal", `${newPartnerPath}/choose-lps`);
    cy.get(
      "input[name='delivery_partner_form[lead_provider_ids][]'][type=checkbox]"
    ).should("have.length", 1);
    cy.chooseFirstLeadProvider();

    cy.location("pathname").should("equal", `${newPartnerPath}/choose-cohorts`);
    cy.get(
      "input[name='delivery_partner_form[provider_relationship_hashes][]'][type=checkbox]"
    ).should("have.length", 1);
    cy.chooseFirstCohort();

    cy.location("pathname").should("equal", `${newPartnerPath}/review`);
    cy.get("main").should("contain", deliveryPartnerName);
    cy.get("main").should("contain", leadProviderName);

    cy.get("main").should("contain", cohortName);
    cy.confirmCreateSupplier();

    cy.location("pathname").should("equal", basePath);
    cy.get("main").should("contain", deliveryPartnerName);
    cy.get("main").should("contain", "Delivery partner created");
  });

  it("remembers previous choices", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const deliveryPartnerName = "New delivery partner";

    cy.visit(basePath);
    cy.clickCreateDeliveryPartnerButton();

    cy.chooseSupplierName(deliveryPartnerName);
    cy.clickBackLink();
    cy.get("input[type=text]").should("have.value", deliveryPartnerName);
    cy.clickCommitButton();

    cy.chooseFirstLeadProviderAndCohort();
    cy.clickBackLink();

    cy.get(
      "[name='delivery_partner_form[lead_provider_ids][]'][type=checkbox]"
    ).should("be.checked");
    cy.clickCommitButton();

    cy.get(
      "[name='delivery_partner_form[provider_relationship_hashes][]'][type=checkbox]"
    ).should("be.checked");
    cy.clickCommitButton();

    cy.get("main").should("contain", deliveryPartnerName);
    cy.get("main").should("contain", leadProviderName);
    cy.get("main").should("contain", cohortName);
    cy.confirmCreateSupplier();

    cy.location("pathname").should("equal", basePath);
    cy.get("main").should("contain", deliveryPartnerName);
  });

  it("allows changing name choice", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const deliveryPartnerName = "New delivery partner";

    cy.visit(basePath);
    cy.clickCreateDeliveryPartnerButton();

    cy.chooseSupplierName("wrong name");
    cy.chooseFirstLeadProviderAndCohort();

    cy.get("a").contains("Change name").click();
    cy.chooseSupplierName(`{selectall}${deliveryPartnerName}`);

    cy.clickCommitButton();
    cy.clickCommitButton();
    cy.confirmCreateSupplier();

    cy.location("pathname").should("equal", basePath);
    cy.get("main").should("contain", deliveryPartnerName);
  });

  describe("Accessibility", () => {
    it("/admin/suppliers is accessible", () => {
      cy.appScenario("admin/suppliers/create_supplier");

      cy.visit(basePath);
      cy.checkA11y();
    });

    it("/admin/suppliers/new/delivery-partner/choose-name", () => {
      cy.appScenario("admin/suppliers/create_supplier");

      cy.visit(basePath);
      cy.clickCreateDeliveryPartnerButton();

      cy.location("pathname").should(
        "equal",
        `${basePath}/new/delivery-partner/choose-name`
      );
      cy.checkA11y();
    });

    it("/admin/suppliers/new/delivery-partner/choose-lps", () => {
      cy.appScenario("admin/suppliers/create_supplier");
      const deliveryPartnerName = "New delivery partner";

      cy.visit(basePath);
      cy.clickCreateDeliveryPartnerButton();
      cy.chooseSupplierName(deliveryPartnerName);
      cy.location("pathname").should(
        "equal",
        `${basePath}/new/delivery-partner/choose-lps`
      );
      cy.checkA11y();
    });

    it("/admin/suppliers/new/delivery-partner/choose-cohorts", () => {
      cy.appScenario("admin/suppliers/create_supplier");
      const deliveryPartnerName = "New delivery partner";

      cy.visit(basePath);
      cy.clickCreateDeliveryPartnerButton();
      cy.chooseSupplierName(deliveryPartnerName);
      cy.chooseFirstLeadProvider();
      cy.location("pathname").should(
        "equal",
        `${basePath}/new/delivery-partner/choose-cohorts`
      );
      cy.checkA11y();
    });

    it("/admin/suppliers/new/delivery-partner/review should be accessible", () => {
      cy.appScenario("admin/suppliers/create_supplier");
      const deliveryPartnerName = "New delivery partner";

      cy.visit(basePath);
      cy.clickCreateDeliveryPartnerButton();
      cy.chooseSupplierName(deliveryPartnerName);
      cy.chooseFirstLeadProviderAndCohort();
      cy.checkA11y();
    });
  });
});
