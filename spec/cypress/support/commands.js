// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

Cypress.Commands.add("login", (...traits) => {
  cy.appFactories([["create", "user", ...traits]])
    .as("userData")
    .then(([user]) => {
      cy.visit(`/users/confirm_sign_in?login_token=${user.login_token}`);
    });

  cy.get('[action="/users/sign_in_with_token"] [name="commit"]').click();
});

Cypress.Commands.add("logout", () => {
  cy.get("#navigation").contains("Logout").click();

  cy.location("pathname").should("eq", "/");
});

Cypress.Commands.add("visitYear", (courseYear) => {
  cy.visit(`/core-induction-programme/years/${courseYear.id}`);
  cy.get("h1").should("contain", courseYear.title);
});

Cypress.Commands.add("visitModule", (courseModule) => {
  cy.visit(
    `/core-induction-programme/years/${courseModule.course_year_id}/modules/${courseModule.id}`
  );
  cy.get("h1").should("contain", courseModule.title);
});

Cypress.Commands.add("visitLesson", (courseLesson) => {
  cy.appEval(
    `CourseModule.find_by(id: "${courseLesson.course_module_id}")`
  ).then((courseModule) => {
    cy.visit(
      `/core-induction-programme/years/${courseModule.course_year_id}/modules/${courseModule.id}/lessons/${courseLesson.id}`
    );
    cy.get("h1").should("contain", courseLesson.title);
  });
});

Cypress.Commands.add("visitModuleOfLesson", (courseLesson) => {
  cy.appEval(
    `CourseModule.find_by(id: "${courseLesson.course_module_id}")`
  ).then((courseModule) => {
    cy.visit(
      `/core-induction-programme/years/${courseModule.course_year_id}/modules/${courseModule.id}`
    );
    cy.get("h1").should("contain", courseModule.title);
  });
});
