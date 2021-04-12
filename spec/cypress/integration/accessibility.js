describe("Accessibility", () => {
  it("Landing page should be accessible", () => {
    cy.visit("/");
    cy.checkA11y();
  });

  it("Login should be accessible", () => {
    cy.visit("/users/sign_in");
    cy.checkA11y();

    // School not registered page
    cy.get('[name="user[email]"]').type("doesntexist@example.com{enter}");
    cy.get("h1").should("contain", "Your school has not registered");
    cy.checkA11y();

    cy.appFactories([["create", "user", "early_career_teacher"]])
      .as("userData")
      .then(([user]) => {
        cy.visit("/users/sign_in");
        cy.get('[name="user[email]"]').type(user.email);
      });

    cy.get('[name="commit"]').contains("Sign in").click();
    cy.get("h1").should("contain", "Check your email");
    cy.checkA11y();

    cy.get("@userData")
      .then(([user]) =>
        // Update user as previous step caused login token to change
        cy.appEval(`User.find_by(id: "${user.id}")`)
      )
      .as("userData")
      .then((user) => {
        cy.visit(`/users/confirm_sign_in?login_token=${user.login_token}`);
      });
    cy.checkA11y();

    cy.get('[action="/users/sign_in_with_token"] [name="commit"]').click();
    cy.get("@userData").then(() => {
      // cy.get("h1").should("contain", `Hi ${user.full_name}`);
    });

    cy.checkA11y();
  });

  it("CIP should be accessible", () => {
    cy.appFactories([["create", "core_induction_programme"]]);

    cy.login("admin");

    cy.visit("/core-induction-programmes");
    cy.checkA11y();

    cy.contains("Test Core induction programme").click();
    cy.checkA11y();

    cy.appFactories([["create", "course_lesson", "with_lesson_part"]]).as(
      "courseLesson"
    );
    cy.get("@courseLesson").then(([lesson]) => {
      cy.visitModuleOfLesson(lesson);

      cy.contains("Test Course module").click();
      cy.checkA11y();

      cy.contains("Test Course lesson").click();
      cy.checkA11y();
    });
  });

  it("Govspeak should be accessible", () => {
    cy.visit("/govspeak_test");

    cy.readFile("cypress/fixtures/govspeak-all.txt").then((text) => {
      // We can't use .type() here as it massively slows down the test
      cy.get("#preview-string-field").invoke(
        "val",
        `${text}\n\n${text.replace("Youtube title", "Youtube title 2")}`
      );
    });

    cy.contains("See preview").click();

    cy.checkA11y();
  });

  // This test should only be ran locally due to the length of time taken to complete.
  // To include it add '--env tags=checkCourseLessonsAccessibility' to the yarn cypress:open cmd.
  if (Cypress.env("tags")?.includes("checkCourseLessonsAccessibility")) {
    it("Visit all course lessons to check for accessibility", () => {
      cy.app("load_seed");
      cy.appEval(`CourseLesson.all`).then((courseLessons) => {
        cy.wrap(courseLessons).each((courseLesson) => {
          cy.visitLesson(courseLesson);
          cy.checkA11y();
        });
      });
    });
  }
});
