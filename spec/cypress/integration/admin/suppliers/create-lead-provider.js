describe("Admin user creating lead provider", () => {
  beforeEach(() => {
    cy.login("admin");
  });

  it("should show a create supplier button", () => {
    cy.visit("/admin/suppliers");
    cy.get(".govuk-button").should("contain", "Add a new supplier");
  });

  it("should create a new lead provider", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const leadProviderName = "New lead provider";

    cy.visit("/admin/suppliers");
    cy.clickCreateSupplierButton();

    cy.location("pathname").should("equal", "/admin/suppliers/new");
    cy.chooseSupplierName(leadProviderName);

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/new/supplier-type"
    );
    cy.chooseLeadProviderType();

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/new/lead-provider/choose-cip"
    );
    cy.get("input[name='lead_provider_form[cip]'][type=radio]").should(
      "have.length",
      1
    );
    cy.chooseFirstCIPForLeadProvider();

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/new/lead-provider/choose-cohorts"
    );
    cy.chooseFirstCohortForLeadProvider();

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/new/lead-provider/review"
    );
    cy.get("main").should("contain", leadProviderName);
    cy.appEval(`CoreInductionProgramme.first.name`).then((cipName) =>
      cy.get("main").should("contain", cipName)
    );
    cy.appEval(
      `LeadProvider.first.cohorts.first.display_name`
    ).then((cohortName) => cy.get("main").should("contain", cohortName));
    cy.confirmCreateSupplier();

    cy.location("pathname").should(
      "contain",
      "/admin/suppliers/new/lead-provider/success"
    );
    cy.get("a").contains("manage suppliers").click();

    cy.location("pathname").should("equal", "/admin/suppliers");
    cy.get("main").should("contain", leadProviderName);

    cy.appEval(
      `LeadProvider.find_by(name: "${leadProviderName}").present?`
    ).then((result) => expect(result).to.equal(true));
  });

  it("remembers previous choices", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const leadProviderName = "New lead provider";

    cy.visit("/admin/suppliers");
    cy.clickCreateSupplierButton();

    cy.chooseSupplierName(leadProviderName);
    cy.clickBackLink();
    cy.get("input[type=text]").should("have.value", leadProviderName);
    cy.clickCommitButton();

    cy.chooseLeadProviderType();
    cy.clickBackLink();
    cy.get("input[type=radio][value=lead_provider]").should("be.checked");
    cy.clickCommitButton();

    cy.chooseFirstCIPForLeadProvider();
    cy.clickBackLink();
    cy.get("input[name='lead_provider_form[cip]'][type=radio]").should(
      "be.checked"
    );
    cy.clickCommitButton();

    cy.chooseFirstCohortForLeadProvider();
    cy.clickBackLink();
    cy.get("input[name='lead_provider_form[cohorts][]'][type=checkbox]").should(
      "be.checked"
    );
    cy.clickCommitButton();

    cy.get("main").should("contain", leadProviderName);
    cy.appEval(`CoreInductionProgramme.first.name`).then((cipName) =>
      cy.get("main").should("contain", cipName)
    );
    cy.appEval(
      `LeadProvider.first.cohorts.first.display_name`
    ).then((cohortName) => cy.get("main").should("contain", cohortName));
    cy.confirmCreateSupplier();

    cy.get("a").contains("manage suppliers").click();

    cy.location("pathname").should("equal", "/admin/suppliers");
    cy.get("main").should("contain", leadProviderName);

    cy.appEval(
      `LeadProvider.find_by(name: "${leadProviderName}").present?`
    ).then((result) => expect(result).to.equal(true));
  });

  it("allows changing name choice", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const leadProviderName = "New lead provider";

    cy.visit("/admin/suppliers");
    cy.clickCreateSupplierButton();

    cy.chooseSupplierName("wrong name");
    cy.chooseLeadProviderType();
    cy.chooseFirstCIPForLeadProvider();
    cy.chooseFirstCohortForLeadProvider();

    cy.get("a").contains("Change name").click();
    cy.chooseSupplierName(`{selectall}${leadProviderName}`);

    cy.clickCommitButton();
    cy.clickCommitButton();
    cy.clickCommitButton();
    cy.confirmCreateSupplier();

    cy.location("pathname").should(
      "contain",
      "/admin/suppliers/new/lead-provider/success"
    );
    cy.get("a").contains("manage suppliers").click();

    cy.location("pathname").should("equal", "/admin/suppliers");
    cy.get("main").should("contain", leadProviderName);

    cy.appEval(
      `LeadProvider.find_by(name: "${leadProviderName}").present?`
    ).then((result) => expect(result).to.equal(true));
  });
});
