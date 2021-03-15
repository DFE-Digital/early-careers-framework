describe("Admin user interaction with Core Induction Programme", () => {
  beforeEach(() => {
    cy.login("admin");
  });

  it("should show a download export button", () => {
    cy.visit("/core-induction-programmes");
    cy.get("a.govuk-button").contains("Download export");
  });

  it("should allow to edit year title", () => {
    cy.appFactories([["create", "course_year"]]).as("courseYear");

    cy.get("@courseYear").then(([year]) => {
      cy.visit(
        `/core-induction-programmes/${year.core_induction_programme_id}`
      );
      cy.get("a.govuk-button").contains("Edit year content").click();

      cy.get("h1").should("contain", "Content change preview");
      cy.get("input[name='title']").type("New title");
      cy.contains("See preview").click();

      cy.get("h1").should("contain", "Content change preview");
      cy.visit(
        `/core-induction-programmes/${year.core_induction_programme_id}`
      );

      cy.get("a.govuk-button").contains("Edit year content").click();
      cy.get("input[name='title']").type("New title");
      cy.contains("Save changes").click();

      cy.get("h2").should("contain", "New title");
    });
  });

  it("should allow to edit module title", () => {
    cy.appFactories([["create", "course_module"]]).as("courseModule");

    cy.get("@courseModule").then(([module]) => {
      cy.visitModule(module);
      cy.get("a.govuk-button").contains("Edit module content").click();

      cy.get("h1").should("contain", "Content change preview");
      cy.get("input[name='course_module[title]']").type("New title");
      cy.contains("See preview").click();

      cy.get("h1").should("contain", "Content change preview");
      cy.visitModule(module);

      cy.get("a.govuk-button").contains("Edit module content").click();
      cy.get("input[name='course_module[title]']").type("New title");
      cy.contains("Save changes").click();

      cy.get("h1").should("contain", "New title");
    });
  });

  it("should allow to edit lesson title", () => {
    cy.appFactories([["create", "course_lesson"]]).as("courseLesson");

    cy.get("@courseLesson").then(([lesson]) => {
      cy.visitLesson(lesson);
      cy.get("a.govuk-button").contains("Edit lesson").click();

      cy.get("h1").should("contain", "Edit lesson");
      cy.get("input[name='course_lesson[title]']").type("New title");
      cy.contains("Save changes").click();

      cy.get("h1").should("contain", "New title");
    });
  });

  it("should allow to edit lesson part title", () => {
    cy.appFactories([["create", "course_lesson", "with_lesson_part"]]).as(
      "courseLesson"
    );

    cy.get("@courseLesson").then(([lesson]) => {
      cy.visitLesson(lesson);
      cy.get("h2").should("contain", "Title");
      cy.get("a.govuk-button").contains("Edit lesson part").click();

      cy.get("h1").should("contain", "Content change preview");
      cy.get("input[name='title']").type("New title");
      cy.contains("See preview").click();

      cy.get("h1").should("contain", "Content change preview");
      cy.visitLesson(lesson);
      cy.get("h2").should("contain", "Title");

      cy.get("a.govuk-button").contains("Edit lesson part").click();
      cy.get("input[name='title']").type("New title");
      cy.contains("Save changes").click();

      cy.get("h2").should("contain", "New title");
    });
  });
});
