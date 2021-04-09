// Heads up, this is NOT used in the Cucumber specs - see factory-bot.js
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

Cypress.Commands.add("visitModule", (courseModule) => {
  cy.visit(`/modules/${courseModule.id}`);
  cy.get("h1").should("contain", courseModule.title);
});

Cypress.Commands.add("visitLesson", (courseLesson) => {
  cy.visit(`/lessons/${courseLesson.id}`);
  cy.get("h1").should("contain", courseLesson.title);
});

Cypress.Commands.add("visitModuleOfLesson", (courseLesson) => {
  cy.appEval(
    `CourseModule.find_by(id: "${courseLesson.course_module_id}")`
  ).then((courseModule) => {
    cy.visit(`/modules/${courseModule.id}`);
    cy.get("h1").should("contain", courseModule.title);
  });
});
