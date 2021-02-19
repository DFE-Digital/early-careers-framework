/**
 * !!!!!
 *
 * This file name starts with aaa so that it runs before all the other tests
 * which rely on the functionality being tested in this file.
 *
 * Please don't rename it!
 */
describe("Meta test helper tests", () => {
  it("should have login and logout helper commands", () => {
    cy.login();
    cy.get("h1").should("contain", "User dashboard");

    cy.logout();
    cy.get("#success-message").should("contain", "Signed out successfully.");
  });

  it("should have factory_bot helper functions", () => {
    cy.app("clean");

    cy.appFactories([["create", "course_lesson", "with_lesson_part"]]).as(
      "courseLesson"
    );

    cy.login();

    cy.visit("/core-induction-programme");

    cy.get('[href*="/core-induction-programme/years"]')
      .contains("Test Course year")
      .click();

    cy.get('[href*="/modules/"]').contains("Test Course module").click();

    cy.get("@courseLesson").then(([lesson]) => {
      cy.url().should("contain", `/modules/${lesson.course_module_id}`);
    });

    cy.get('[href*="/lessons/"]').contains("Test Course lesson").click();

    cy.get("@courseLesson").then(([lesson]) => {
      cy.url().should("contain", `/lessons/${lesson.id}`);
    });

    cy.get("h1").should("contain", "Test Course lesson");
    cy.get(".govuk-govspeak").should("contain", "No content");
  });

  it("should have a cleanable database", () => {
    cy.app("clean");

    cy.appFactories([
      ["create", "course_lesson"],
      ["create", "course_lesson"],
      ["create", "course_lesson"],
    ]);

    cy.visit("/core-induction-programme");

    cy.get('.govuk-link:contains("Test Course year")').should("have.length", 3);

    cy.app("clean");

    cy.reload();

    cy.get('.govuk-link:contains("Test Course year")').should("have.length", 0);
    cy.contains("No course years were found!");
  });

  it("should start with a clean database", () => {
    cy.login("admin");

    cy.get('.govuk-link:contains("Lead Provider")').should("have.length", 0);
  });
});
