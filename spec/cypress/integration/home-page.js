describe("Home page", () => {
  it("should have feedback link", () => {
    cy.visit("/");

    cy.contains("a", "feedback").should(
      "have.attr",
      "href",
      "mailto:continuing-professional-development@digital.education.gov.uk"
    );
  });
});
