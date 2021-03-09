describe("Admin user creating delivery partner", () => {
  beforeEach(() => {
    cy.login("admin");
  });

  it("should show a create supplier button", () => {
    cy.visit("/admin/suppliers");
    cy.get(".govuk-button").should("contain", "Add a new supplier");
  });

  it("should create a new delivery partner", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const deliveryPartnerName = "New delivery partner";

    cy.visit("/admin/suppliers");
    cy.get(".govuk-button").contains("Add a new supplier").click();

    cy.location("pathname").should("equal", "/admin/suppliers/new");
    cy.chooseSupplierName(deliveryPartnerName);

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/new/supplier-type"
    );
    cy.chooseDeliveryPartnerType();

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/new/delivery-partner/choose-lps"
    );
    cy.get(
      "input[name='delivery_partner_form[lead_providers][]'][type=checkbox]"
    ).should("have.length", 1);
    cy.get(
      "input[name='delivery_partner_form[provider_relationship_hashes][]'][type=checkbox]"
    ).should("have.length", 1);
    cy.chooseFirstLeadProviderAndCohort();

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/new/delivery-partner/review"
    );
    cy.get("main").should("contain", deliveryPartnerName);
    cy.appEval(`LeadProvider.first.name`).then((leadProviderName) =>
      cy.get("main").should("contain", leadProviderName)
    );
    cy.appEval(
      `LeadProvider.first.cohorts.first.display_name`
    ).then((cohortName) => cy.get("main").should("contain", cohortName));
    cy.confirmCreateSupplier();

    cy.location("pathname").should(
      "contain",
      "/admin/suppliers/new/delivery-partner/success"
    );
    cy.get("a").contains("manage suppliers").click();

    cy.location("pathname").should("equal", "/admin/suppliers");
    cy.get("main").should("contain", deliveryPartnerName);

    cy.appEval(
      `DeliveryPartner.find_by(name: "${deliveryPartnerName}").present?`
    ).then((result) => expect(result).to.equal(true));
  });

  it("remembers previous choices", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const deliveryPartnerName = "New delivery partner";

    cy.visit("/admin/suppliers");
    cy.get(".govuk-button").contains("Add a new supplier").click();

    cy.chooseSupplierName(deliveryPartnerName);
    cy.clickBackLink();
    cy.get("input[type=text]").should("have.value", deliveryPartnerName);
    cy.get(".govuk-button").click();

    cy.chooseDeliveryPartnerType();
    cy.clickBackLink();
    cy.get("input[type=radio][value=delivery_partner]").should("be.checked");
    cy.get(".govuk-button").click();

    cy.chooseFirstLeadProviderAndCohort();
    cy.clickBackLink();
    cy.get(
      "[name='delivery_partner_form[lead_providers][]'][type=checkbox]"
    ).should("be.checked");
    cy.get(
      "[name='delivery_partner_form[provider_relationship_hashes][]'][type=checkbox]"
    ).should("be.checked");
    cy.get(".govuk-button").click();

    cy.get("main").should("contain", deliveryPartnerName);
    cy.appEval(`LeadProvider.first.name`).then((leadProviderName) =>
      cy.get("main").should("contain", leadProviderName)
    );
    cy.appEval(
      `LeadProvider.first.cohorts.first.display_name`
    ).then((cohortName) => cy.get("main").should("contain", cohortName));
    cy.confirmCreateSupplier();

    cy.location("pathname").should(
      "contain",
      "/admin/suppliers/new/delivery-partner/success"
    );
    cy.get("a").contains("manage suppliers").click();

    cy.location("pathname").should("equal", "/admin/suppliers");
    cy.get("main").should("contain", deliveryPartnerName);

    cy.appEval(
      `DeliveryPartner.find_by(name: "${deliveryPartnerName}").present?`
    ).then((result) => expect(result).to.equal(true));
  });

  it("allows changing name choice", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const deliveryPartnerName = "New delivery partner";

    cy.visit("/admin/suppliers");
    cy.get(".govuk-button").contains("Add a new supplier").click();

    cy.chooseSupplierName("wrong name");
    cy.chooseDeliveryPartnerType();
    cy.chooseFirstLeadProviderAndCohort();

    cy.get("a").contains("Change name").click();
    cy.chooseSupplierName(`{selectall}${deliveryPartnerName}`);

    cy.get(".govuk-button").click();
    cy.get(".govuk-button").click();
    cy.confirmCreateSupplier();

    cy.location("pathname").should(
      "contain",
      "/admin/suppliers/new/delivery-partner/success"
    );
    cy.get("a").contains("manage suppliers").click();

    cy.location("pathname").should("equal", "/admin/suppliers");
    cy.get("main").should("contain", deliveryPartnerName);

    cy.appEval(
      `DeliveryPartner.find_by(name: "${deliveryPartnerName}").present?`
    ).then((result) => expect(result).to.equal(true));
  });
});
