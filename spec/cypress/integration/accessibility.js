describe("Accessibility", () => {
  it("Landing page should be accessible", () => {
    cy.visit("/");
    cy.checkA11y();
  });

  it("Login should be accessible", () => {
    cy.visit("/users/sign_in");
    cy.checkA11y();
    cy.percySnapshot("Login page");

    // School not registered page
    cy.get('[name="user[email]"]').type("doesntexist@example.com{enter}");
    cy.titleShouldEqual("Check email");
    cy.checkA11y();
    cy.appSentEmails().then((emails) => {
      expect(emails).to.have.lengthOf(0);
    });

    cy.appFactories([["create", "user"]])
      .as("userData")
      .then(([user]) => {
        cy.visit("/users/sign_in");
        cy.get('[name="user[email]"]').type(user.email);
      });

    cy.get('[name="commit"]').contains("Sign in").click();
    cy.titleShouldEqual("Check email");
    cy.checkA11y();
    cy.percySnapshot("Check email page");

    cy.get("@userData").then(([user]) => {
      cy.verifySignInEmailSentToUser(user);
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
    cy.percySnapshot("Confirm sign in page");

    cy.get('[action="/users/sign_in_with_token"] [name="commit"]').click();
    cy.get("h1").should("contain", "You cannot use this service yet");
    cy.checkA11y();

    cy.logout();
    cy.checkA11y();
    cy.percySnapshot("Logout page");
  });

  it("Login link invalid page should be accessible", () => {
    cy.visit("/users/link-invalid");
    cy.checkA11y();
    cy.percySnapshot();
  });
});
