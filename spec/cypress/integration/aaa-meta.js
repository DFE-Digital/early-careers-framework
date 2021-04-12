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
    cy.url().should("contain", "/dashboard");

    cy.logout();
    cy.get("#success-message").should("contain", "Signed out successfully.");
  });

  it("should have factory_bot helper functions", () => {
    cy.app("clean");

    cy.appFactories([["create", "course_lesson", "with_lesson_part"]]).as(
      "courseLesson"
    );

    cy.login();

    cy.get("@courseLesson").then(([lesson]) => {
      cy.visitModuleOfLesson(lesson);
      cy.url().should("contain", `/modules/${lesson.course_module_id}`);
    });

    cy.get("@courseLesson").then(([lesson]) => {
      cy.visitLesson(lesson);
      cy.get(".govuk-govspeak").should("contain", "No content");
    });
  });

  it("should have a cleanable database", () => {
    cy.app("clean");

    cy.appFactories([
      ["create", "core_induction_programme"],
      ["create", "core_induction_programme"],
      ["create", "core_induction_programme"],
    ]);

    cy.login("admin");

    cy.visit("/core-induction-programmes");

    cy.get('.govuk-link:contains("Test Core induction programme")').should(
      "have.length",
      3
    );

    cy.app("clean");
    cy.login("admin");
    cy.visit("/core-induction-programmes");

    cy.get('.govuk-link:contains("Test Core induction programme")').should(
      "have.length",
      0
    );
    cy.contains("No courses were found!");
  });

  it("should start with a clean database", () => {
    cy.login("admin");

    cy.get('.govuk-link:contains("Lead Provider")').should("have.length", 0);
  });
});
