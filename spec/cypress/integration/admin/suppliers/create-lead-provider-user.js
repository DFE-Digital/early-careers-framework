describe("Admin user creating lead provider user", () => {
  beforeEach(() => {
    cy.login("admin");
  });

  it("should show a create supplier user button", () => {
    cy.visit("/admin/suppliers/users");
    cy.get(".govuk-button").should("contain", "Add a new user");
  });

  it("should create a new lead provider", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const userName = "John Smith";
    const userEmail = "j.s@example.com";

    cy.visit("/admin/suppliers/users");
    cy.get(".govuk-button").click();

    cy.location("pathname").should("equal", "/admin/suppliers/users/new");
    cy.chooseLeadProviderName();

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/users/new/user-details"
    );
    cy.chooseNameAndEmail(userName, userEmail);

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/users/new/review"
    );
    cy.get("main").should("contain", userName);
    cy.get("main").should("contain", userEmail);
    cy.confirmCreateSupplierUser();

    cy.location("pathname").should(
      "contain",
      "/admin/suppliers/users/new/success"
    );

    cy.get("a").contains("manage suppliers").click();
    cy.location("pathname").should("equal", "/admin/suppliers");

    cy.get("a").contains("All users").click();
    cy.location("pathname").should("equal", "/admin/suppliers/users");
    cy.get("main").should("contain", userName);
    cy.get("main").should("contain", userEmail);
    cy.appEval(`LeadProvider.first.name`).then((leadProviderName) =>
      cy.get("main").should("contain", leadProviderName)
    );

    cy.appEval(`User.find_by(email: "${userEmail}").present?`).then((result) =>
      expect(result).to.equal(true)
    );
    cy.appEval(
      `User.find_by(email: "${userEmail}").lead_provider.present?`
    ).then((result) => expect(result).to.equal(true));
  });

  it("remembers previous choices", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const userName = "John Smith";
    const userEmail = "j.s@example.com";

    cy.visit("/admin/suppliers/users");
    cy.get(".govuk-button").click();

    cy.chooseLeadProviderName();
    cy.clickBackLink();
    cy.appEval(`LeadProvider.first.name`).then((leadProviderName) => {
      cy.get("input[type=text]").should("have.value", leadProviderName);
      cy.get(".govuk-button").click();
    });

    cy.chooseNameAndEmail(userName, userEmail);
    cy.clickBackLink();
    cy.get("input[name='supplier_user_form[full_name]'").should(
      "have.value",
      userName
    );
    cy.get("input[name='supplier_user_form[email]'").should(
      "have.value",
      userEmail
    );
    cy.get(".govuk-button").click();

    cy.confirmCreateSupplierUser();

    cy.get("a").contains("manage suppliers").click();
    cy.location("pathname").should("equal", "/admin/suppliers");

    cy.get("a").contains("All users").click();
    cy.location("pathname").should("equal", "/admin/suppliers/users");
    cy.get("main").should("contain", userName);
    cy.get("main").should("contain", userEmail);
    cy.appEval(`LeadProvider.first.name`).then((leadProviderName) =>
      cy.get("main").should("contain", leadProviderName)
    );

    cy.appEval(`User.find_by(email: "${userEmail}").present?`).then((result) =>
      expect(result).to.equal(true)
    );
    cy.appEval(
      `User.find_by(email: "${userEmail}").lead_provider.present?`
    ).then((result) => expect(result).to.equal(true));
  });

  it.only("allows changing name choice", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const userName = "John Smith";
    const userEmail = "j.s@example.com";

    cy.visit("/admin/suppliers/users");
    cy.get(".govuk-button").click();

    cy.chooseLeadProviderName();
    cy.chooseNameAndEmail("wrongName", userEmail);

    cy.get("a").contains("Change name").click();
    cy.chooseNameAndEmail(`{selectall}${userName}`, `{selectall}${userEmail}`);

    cy.confirmCreateSupplierUser();

    cy.get("a").contains("manage suppliers").click();
    cy.location("pathname").should("equal", "/admin/suppliers");

    cy.get("a").contains("All users").click();
    cy.location("pathname").should("equal", "/admin/suppliers/users");
    cy.get("main").should("contain", userName);
    cy.get("main").should("contain", userEmail);
    cy.appEval(`LeadProvider.first.name`).then((leadProviderName) =>
      cy.get("main").should("contain", leadProviderName)
    );

    cy.appEval(`User.find_by(email: "${userEmail}").present?`).then((result) =>
      expect(result).to.equal(true)
    );
    cy.appEval(`User.find_by(email: "${userEmail}").full_name`).then((result) =>
      expect(result).to.equal(userName)
    );
  });
});
