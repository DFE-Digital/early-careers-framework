describe("Admin user creating lead provider user", () => {
  const leadProviderName = "Lead Provider 1";

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
    cy.clickCreateSupplierUserButton();

    cy.location("pathname").should("equal", "/admin/suppliers/users/new");
    cy.chooseLeadProviderName(leadProviderName);

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/users/new/user-details"
    );
    cy.chooseNameAndEmailForLeadProviderUser(userName, userEmail);

    cy.location("pathname").should(
      "equal",
      "/admin/suppliers/users/new/review"
    );
    cy.get("main").should("contain", userName);
    cy.get("main").should("contain", userEmail);
    cy.confirmCreateSupplierUser();

    cy.location("pathname").should("equal", "/admin/suppliers/users");
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

    cy.visit("/admin/suppliers/users");
    cy.clickCreateSupplierUserButton();

    cy.chooseLeadProviderName(leadProviderName);
    cy.clickBackLink();
    cy.get("input[type=text]").should("have.value", leadProviderName);
    cy.clickCommitButton();

    cy.chooseNameAndEmailForLeadProviderUser(userName, userEmail);
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

    cy.location("pathname").should("equal", "/admin/suppliers/users");
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

    cy.visit("/admin/suppliers/users");
    cy.clickCreateSupplierUserButton();

    cy.chooseLeadProviderName(leadProviderName);
    cy.chooseNameAndEmailForLeadProviderUser("wrongName", userEmail);

    cy.get("a").contains("Change name").click();
    cy.chooseNameAndEmailForLeadProviderUser(
      `{selectall}${userName}`,
      `{selectall}${userEmail}`
    );

    cy.confirmCreateSupplierUser();

    cy.location("pathname").should("equal", "/admin/suppliers/users");
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
});
