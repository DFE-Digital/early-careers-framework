import "cypress-axe";

Cypress.Commands.overwrite("injectAxe", (orig, options) => {
  orig(options);

  cy.configureAxe({
    rules: [{ id: "region", enabled: false }],
  });
});

Cypress.Commands.overwrite("checkA11y", (orig, ...args) => {
  // It doesn't seem to affect anything if injectAxe is ran multiple times
  cy.injectAxe();

  orig(...args);
});
