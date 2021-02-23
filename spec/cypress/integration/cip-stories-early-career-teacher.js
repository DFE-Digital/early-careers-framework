describe("ECT user interaction with Core Induction Programme", () => {
  beforeEach(() => {
    cy.login("early_career_teacher");
  });

  it("should not show a download export button", () => {
    cy.visit("/core-induction-programme");
    cy.contains("a.govuk-button", "Download export").should("not.exist");
  });

  it("should not allow to edit year title", () => {
    cy.appFactories([["create", "course_year"]]).as("courseYear");

    cy.get("@courseYear").then(([year]) => {
      cy.visitYear(year);
      cy.contains("a.govuk-button", "Edit year content").should("not.exist");
    });
  });

  it("should not allow to edit module title", () => {
    cy.appFactories([["create", "course_module"]]).as("courseModule");

    cy.get("@courseModule").then(([module]) => {
      cy.visitModule(module);
      cy.contains("a.govuk-button", "Edit module content").should("not.exist");
    });
  });

  it("should not allow to edit lesson title", () => {
    cy.appFactories([["create", "course_lesson"]]).as("courseLesson");

    cy.get("@courseLesson").then(([lesson]) => {
      cy.visitLesson(lesson);
      cy.contains("a.govuk-button", "Edit lesson").should("not.exist");
    });
  });

  it("should not allow to edit lesson part title", () => {
    cy.appFactories([["create", "course_lesson", "with_lesson_part"]]).as(
      "courseLesson"
    );

    cy.get("@courseLesson").then(([lesson]) => {
      cy.visitLesson(lesson);
      cy.get("h2").should("contain", "Title");
      cy.contains("a.govuk-button", "Edit lesson content").should("not.exist");
    });
  });

  it("should display lesson progress", () => {
    cy.appFactories([["create", "course_lesson", "with_lesson_part"]]).as(
      "courseLesson"
    );

    cy.get("@courseLesson").then(([lesson]) => {
      cy.visitModuleOfLesson(lesson);
      cy.contains("strong.govuk-tag", "not started");

      cy.visitLesson(lesson);
      cy.visitModuleOfLesson(lesson);
      cy.contains("strong.govuk-tag", "in progress");

      cy.visitLesson(lesson);
      cy.get('[type="checkbox"]').check();
      cy.get("form").submit();
      cy.contains("strong.govuk-tag", "complete");
    });
  });
});
