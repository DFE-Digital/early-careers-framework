describe("Admin user creating lead provider user", () => {
  const basePath = "/admin/suppliers/users";
  const leadProviderName = "Lead Provider 1";

  beforeEach(() => {
    cy.login("admin");
  });

  it("should create a new lead provider", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const userName = "John Smith";
    const userEmail = "j.s@example.com";

    cy.visit(basePath);
    cy.clickCreateSupplierUserButton();

    cy.location("pathname").should("equal", `${basePath}/new`);
    cy.chooseLeadProviderName(leadProviderName);

    cy.location("pathname").should("equal", `${basePath}/new/user-details`);
    cy.chooseNameAndEmailForUser(userName, userEmail);

    cy.location("pathname").should("equal", `${basePath}/new/review`);
    cy.get("main").should("contain", userName);
    cy.get("main").should("contain", userEmail);
    cy.confirmCreateSupplierUser();

    cy.location("pathname").should("equal", basePath);
    cy.get("main").should("contain", userName);
    cy.get("main").should("contain", userEmail);
    cy.get("main").should("contain", leadProviderName);
    cy.get("[data-test=notification-banner]").should("contain", "Success");
    cy.get("[data-test=notification-banner]").should("contain", "User added");
    cy.get("[data-test=notification-banner]").should(
      "contain",
      "They have been sent an email to sign in"
    );
  });

  it("remembers previous choices", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const userName = "John Smith";
    const userEmail = "j.s@example.com";

    cy.visit(basePath);
    cy.clickCreateSupplierUserButton();

    cy.chooseLeadProviderName(leadProviderName);
    cy.clickBackLink();
    cy.get("input[type=text]").should("have.value", leadProviderName);
    cy.clickCommitButton();

    cy.chooseNameAndEmailForUser(userName, userEmail);
    cy.clickBackLink();
    cy.get("input[name='supplier_user_form[full_name]'").should(
      "have.value",
      userName
    );
    cy.get("input[name='supplier_user_form[email]'").should(
      "have.value",
      userEmail
    );
    cy.clickCommitButton();

    cy.confirmCreateSupplierUser();

    cy.location("pathname").should("equal", basePath);
    cy.get("main").should("contain", userName);
    cy.get("main").should("contain", userEmail);
    cy.get("main").should("contain", leadProviderName);
    cy.get("[data-test=notification-banner]").should("contain", "Success");
    cy.get("[data-test=notification-banner]").should("contain", "User added");
    cy.get("[data-test=notification-banner]").should(
      "contain",
      "They have been sent an email to sign in"
    );
  });

  it("allows changing name choice", () => {
    cy.appScenario("admin/suppliers/create_supplier");
    const userName = "John Smith";
    const userEmail = "j.s@example.com";

    cy.visit(basePath);
    cy.clickCreateSupplierUserButton();

    cy.chooseLeadProviderName(leadProviderName);
    cy.chooseNameAndEmailForUser("wrongName", userEmail);

    cy.get("a").contains("Change name").click();
    cy.chooseNameAndEmailForUser(
      `{selectall}${userName}`,
      `{selectall}${userEmail}`
    );

    cy.confirmCreateSupplierUser();

    cy.location("pathname").should("equal", basePath);
    cy.get("main").should("contain", userName);
    cy.get("main").should("contain", userEmail);
    cy.get("main").should("contain", leadProviderName);
    cy.get("main").should("contain", "User added");
    cy.get("[data-test=notification-banner]").should("contain", "Success");
    cy.get("[data-test=notification-banner]").should("contain", "User added");
    cy.get("[data-test=notification-banner]").should(
      "contain",
      "They have been sent an email to sign in"
    );
  });

  describe("Accessibility", () => {
    it("/admin/suppliers/users should be accessible", () => {
      cy.appScenario("admin/suppliers/create_supplier");

      cy.visit(basePath);
      cy.checkA11y();
    });

    it("/admin/suppliers/users/new should be accessible", () => {
      cy.appScenario("admin/suppliers/create_supplier");

      cy.visit(basePath);
      cy.clickCreateSupplierUserButton();

      cy.location("pathname").should("equal", `${basePath}/new`);
      cy.checkA11y();
    });

    it("/admin/suppliers/users/new/user-details should be accessible", () => {
      cy.appScenario("admin/suppliers/create_supplier");

      cy.visit(basePath);
      cy.clickCreateSupplierUserButton();

      cy.chooseLeadProviderName(leadProviderName);

      cy.location("pathname").should("equal", `${basePath}/new/user-details`);
      cy.checkA11y();
    });

    it("/admin/suppliers/users/new/review should be accessible", () => {
      cy.appScenario("admin/suppliers/create_supplier");
      const userName = "John Smith";
      const userEmail = "j.s@example.com";

      cy.visit(basePath);
      cy.clickCreateSupplierUserButton();

      cy.chooseLeadProviderName(leadProviderName);

      cy.chooseNameAndEmailForUser(userName, userEmail);

      cy.location("pathname").should("equal", `${basePath}/new/review`);
      cy.checkA11y();
    });
  });
});
