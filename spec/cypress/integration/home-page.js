describe("Home page", () => {
  it("should have feedback link pointing to support email from config", () => {
    cy.visit("/");

    cy.contains("a", "feedback").should(
      "have.attr",
      "href",
      "mailto:ecf-support@example.com"
    );
  });
});
