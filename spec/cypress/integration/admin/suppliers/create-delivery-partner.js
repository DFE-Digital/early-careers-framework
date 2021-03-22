describe("Admin user creating delivery partner", () => {
  const basePath = "/admin/suppliers";
  const leadProviderName = "Lead Provider 1";
  const cohortName = "2021";
  const deliveryPartnerName = "New delivery partner";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should create a new delivery partner", () => {
    cy.appScenario("admin/suppliers/create_supplier");

    cy.visit(basePath);
    cy.clickCreateDeliveryPartnerButton();

    cy.titleShouldEqual("Add partner");
    cy.chooseSupplierName(deliveryPartnerName);

    cy.titleShouldEqual("Choose providers");
    cy.get(
      "input[name='delivery_partner_form[lead_provider_ids][]'][type=checkbox]"
    ).should("have.length", 1);
    cy.chooseFirstLeadProvider();

    cy.titleShouldEqual("Choose cohorts");
    cy.get(
      "input[name='delivery_partner_form[provider_relationship_hashes][]'][type=checkbox]"
    ).should("have.length", 1);
    cy.chooseFirstCohort();

    cy.titleShouldEqual("Confirm partner");
    cy.get("main").should("contain", deliveryPartnerName);
    cy.get("main").should("contain", leadProviderName);

    cy.get("main").should("contain", cohortName);
    cy.confirmCreateSupplier();

    cy.titleShouldEqual("Suppliers");
    cy.get("main").should("contain", deliveryPartnerName);
    cy.get("main").should("contain", "Delivery partner created");
  });

  it("remembers previous choices", () => {
    cy.appScenario("admin/suppliers/create_supplier");

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

    cy.titleShouldEqual("Suppliers");
    cy.get("main").should("contain", deliveryPartnerName);
  });

  it("allows changing name choice", () => {
    cy.appScenario("admin/suppliers/create_supplier");

    cy.visit(basePath);
    cy.clickCreateDeliveryPartnerButton();

    cy.chooseSupplierName("wrong name");
    cy.chooseFirstLeadProviderAndCohort();

    cy.get("a").contains("Change name").click();
    cy.chooseSupplierName(`{selectall}${deliveryPartnerName}`);

    cy.clickCommitButton();
    cy.clickCommitButton();
    cy.confirmCreateSupplier();

    cy.titleShouldEqual("Suppliers");
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

      cy.titleShouldEqual("Add partner");
      cy.checkA11y();
    });

    it("/admin/suppliers/new/delivery-partner/choose-lps", () => {
      cy.appScenario("admin/suppliers/create_supplier");

      cy.visit(basePath);
      cy.clickCreateDeliveryPartnerButton();
      cy.chooseSupplierName(deliveryPartnerName);
      cy.titleShouldEqual("Choose providers");
      cy.checkA11y();
    });

    it("/admin/suppliers/new/delivery-partner/choose-cohorts", () => {
      cy.appScenario("admin/suppliers/create_supplier");

      cy.visit(basePath);
      cy.clickCreateDeliveryPartnerButton();
      cy.chooseSupplierName(deliveryPartnerName);
      cy.chooseFirstLeadProvider();
      cy.titleShouldEqual("Choose cohorts");
      cy.checkA11y();
    });

    it("/admin/suppliers/new/delivery-partner/review should be accessible", () => {
      cy.appScenario("admin/suppliers/create_supplier");

      cy.visit(basePath);
      cy.clickCreateDeliveryPartnerButton();
      cy.chooseSupplierName(deliveryPartnerName);
      cy.chooseFirstLeadProviderAndCohort();
      cy.titleShouldEqual("Confirm partner");
      cy.checkA11y();
    });
  });
});
