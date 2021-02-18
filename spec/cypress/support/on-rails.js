// CypressOnRails: don't remove these command
Cypress.Commands.add("appCommands", (body) => {
  cy.log(`APP: ${JSON.stringify(body)}`);
  return cy
    .request({
      method: "POST",
      url: "/__cypress__/command",
      body: JSON.stringify(body),
      log: true,
      failOnStatusCode: true,
    })
    .then((response) => response.body);
});

Cypress.Commands.add("app", (name, commandOptions) =>
  cy.appCommands({ name, options: commandOptions }).then((body) => body[0])
);

Cypress.Commands.add("appScenario", (name, options = {}) =>
  cy.app(`scenarios/${name}`, options)
);

Cypress.Commands.add("appEval", (code) => cy.app("eval", code));

Cypress.Commands.add("appFactories", (options) =>
  cy.app("factory_bot", options)
);

Cypress.Commands.add("appFixtures", (options) => {
  cy.app("activerecord_fixtures", options);
});
// CypressOnRails: end

beforeEach(() => {
  cy.app("clean");
});

// comment this out if you do not want to attempt to log additional info on test fail
Cypress.on("fail", (err, runnable) => {
  // allow app to generate additional logging data
  Cypress.$.ajax({
    url: "/__cypress__/command",
    data: JSON.stringify({
      name: "log_fail",
      options: {
        error_message: err.message,
        runnable_full_title: runnable.fullTitle(),
      },
    }),
    async: false,
    method: "POST",
  });

  throw err;
});
