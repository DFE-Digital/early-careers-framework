describe("Example tests", function () {
  beforeEach(() => {
    cy.app("clean");
  });

  // This is an example of a failing test - skipping because it takes a while to run
  it.skip("should be viewable when logged out", () => {
    cy.appFactories([["create", "course_lesson"]]);

    cy.visit("/");

    cy.get("#navigation").contains("Core Induction Programme").click();

    cy.get("h1").should("contain", "What is the early career framework?");

    cy.contains("Test Course year").click();

    cy.get("h1").should("contain", "Test Course year");
    cy.get(".govuk-govspeak").should("contain", "No content");

    cy.get("a").contains("Test Course module").click();

    cy.get("h1").should("contain", "Test Course module");
    cy.get(".govuk-govspeak").should("contain", "No content");

    cy.get(".app-task-list .govuk-tag").should("not.exist");

    // Above test will fail for demo so not much point continuing…
    cy.get("a").contains("Test Course lesson").click();
  });

  it("should not be editable when logged in as non-admin user", () => {
    cy.appFactories([
      ["create", "user"],
      ["create", "course_lesson"],
    ]);

    // @todo appFactories returns this
    cy.appEval("User.last").then((res) => {
      Cypress.config("user", res);
      cy.visit(`/users/confirm_sign_in?login_token=${res.login_token}`);
    });

    cy.get('[action="/users/sign_in_with_token"] [name="commit"]').click();

    cy.get("h1").should("contain", "User dashboard");

    cy.get("#navigation").contains("Core Induction Programme").click();

    cy.contains('Download export').should('not.exist');

    cy.contains('Test Course year').click();

    cy.contains('Edit year content').should('not.exist');

    cy.contains('Test Course module').click();

    cy.contains('Edit module content').should('not.exist');

    cy.contains('Test Course lesson').click();

    cy.contains('Edit lesson content').should('not.exist');
  });

  it("should be editable when logged in as admin user", () => {
    cy.appFactories([
      ["create", "user", "admin"],
      ["create", "course_lesson"],
    ]);

    // @todo appFactories returns this
    cy.appEval("User.last").then((res) => {
      Cypress.config("user", res);
      cy.visit(`/users/confirm_sign_in?login_token=${res.login_token}`);
    });

    cy.get('[action="/users/sign_in_with_token"] [name="commit"]').click();

    // Sometimes factorybot fails to create an admin user and this fails
    cy.get("h1").should("contain", "Suppliers");

    cy.get("#navigation").contains("Core Induction Programme").click();

    cy.get('.govuk-button').contains('Download export');

    cy.contains('Test Course year').click();

    cy.get('.govuk-button').contains('Edit year content');

    cy.contains('Test Course module').click();

    cy.get('.govuk-button').contains('Edit module content');

    cy.contains('Test Course lesson').click();

    cy.get('.govuk-button').contains('Edit lesson content').click();

    const testText = 'Some test content in cypress'
    cy.get('#lesson-preview-field').clear().type(testText);

    cy.contains('See preview').click();

    cy.get('.govuk-govspeak').should('contain', testText);
    cy.contains('Your changes have been saved').should('not.exist');

    cy.contains('Save changes').click();

    cy.get('.govuk-govspeak').should('contain', testText);
    cy.contains('Your changes have been saved');
  });

  it('accessible autocomoplete', () => {
    cy.visit('https://alphagov.github.io/accessible-autocomplete/examples/');

    cy.get('#autocomplete-default').type('United');

    cy.get('.autocomplete__menu').contains('United Kingdom').click();

    cy.get('#autocomplete-default').should('value', 'United Kingdom');
  });
});
