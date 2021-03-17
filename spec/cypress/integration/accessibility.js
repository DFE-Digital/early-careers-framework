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
    cy.get("h1").should("contain", "You do not have an account");
    cy.checkA11y();
    cy.appSentEmails().then((emails) => {
      expect(emails).to.have.lengthOf(0);
    });

    cy.appFactories([["create", "user", "early_career_teacher"]])
      .as("userData")
      .then(([user]) => {
        cy.visit("/users/sign_in");
        cy.get('[name="user[email]"]').type(user.email);
      });

    cy.get('[name="commit"]').contains("Sign in").click();
    cy.get("h1").should("contain", "Check your email");
    cy.checkA11y();

    cy.get("@userData").then(([user]) => {
      cy.verifySignInEmailSent(user);
    });

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
    cy.get("h1").should("contain", "User dashboard");
    cy.checkA11y();
  });

  it("Admin suppliers should be accessible", () => {
    cy.login("admin");
    cy.get("h1").should("contain", "Suppliers");
    cy.checkA11y();
  });
});
