describe("Cookie consent", () => {
  const basePath = "/cookies";

  it("should be settable on a cookies page", () => {
    cy.visit(basePath);

    cy.get('[name="cookies_form[analytics_consent]"]')
      .should("not.be.checked")
      .get('[value="on"]')
      .click();

    cy.get('[name="commit"]').click();

    // @todo replace with visual test
    cy.contains("You’ve set your cookie preferences.");

    cy.get('[name="cookies_form[analytics_consent]"]')
      .as("cookieRadios")
      .get('[value="on"]')
      .should("be.checked");

    cy.get("@cookieRadios").get('[value="off"]').click();

    cy.get('[name="commit"]').click();

    cy.contains("You’ve set your cookie preferences.");

    cy.get('[name="cookies_form[analytics_consent]"][value="off"]').should(
      "be.checked"
    );
  });

  it("should be settable through a cookie banner without js", () => {
    cy.visit("/?nojs=nojs");

    cy.get(".js-cookie-form").contains("Accept").click();

    cy.contains("You’ve set your cookie preferences.");

    cy.get('[name="cookies_form[analytics_consent]"][value="on"]').should(
      "be.checked"
    );
  });

  it("should be settable through a cookie banner with js", () => {
    cy.visit("/");

    cy.get(".js-cookie-form").contains("Accept").click();

    cy.contains("You've accepted analytics cookies.");

    cy.get(".js-cookie-banner").contains("Hide this message").click();

    cy.get(".js-cookie-banner").should("not.be.visible");

    cy.visit(basePath);

    cy.get('[name="cookies_form[analytics_consent]"][value="on"]').should(
      "be.checked"
    );

    cy.visit("/");

    cy.get(".js-cookie-banner").should("not.exist");

    cy.clearCookies();

    cy.visit("/");

    cy.get(".js-cookie-form").contains("Reject").click();

    cy.contains("You've rejected analytics cookies.");

    cy.get(".js-cookie-banner").contains("Hide this message").click();

    cy.get(".js-cookie-banner").should("not.be.visible");

    cy.visit(basePath);

    cy.get('[name="cookies_form[analytics_consent]"][value="off"]').should(
      "be.checked"
    );

    cy.visit("/");

    cy.get(".js-cookie-banner").should("not.exist");
  });
});
