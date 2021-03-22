import "cypress-axe";

Cypress.Commands.overwrite("injectAxe", () => {
  // cypress-axe doesn't like @cypress/browserify-preprocessor which was added
  // by cypress-cucumber-preprocessor
  // https://github.com/component-driven/cypress-axe/issues/6#issuecomment-726986454
  cy.window({ log: false }).then((win) => {
    // eslint-disable-next-line global-require
    const axe = require("axe-core/axe.js");
    const script = win.document.createElement("script");
    script.innerHTML = axe.source;
    win.document.head.appendChild(script);
  });

  cy.configureAxe({
    rules: [{ id: "region", enabled: false }],
  });
});

Cypress.Commands.overwrite("checkA11y", (orig, ...args) => {
  // It doesn't seem to affect anything if injectAxe is ran multiple times
  cy.injectAxe();

  orig(...args);
});
