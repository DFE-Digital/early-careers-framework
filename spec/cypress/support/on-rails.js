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

let createdRecords = {};
export default {
  getCreatedRecord(factory, givenIndex = -1) {
    if (!createdRecords[factory]) {
      return null;
    }

    let index = givenIndex;
    if (index < 0) {
      index = createdRecords[factory].length + index;
    }
    return createdRecords[factory][index];
  },
};

Cypress.Commands.add("app", (name, commandOptions) =>
  cy.appCommands({ name, options: commandOptions }).then((body) => body[0])
);

Cypress.Commands.add("appScenario", (name, options = {}) =>
  cy.app(`scenarios/${name}`, options)
);

Cypress.Commands.add("appEval", (code) => cy.app("eval", code));

Cypress.Commands.add("appFactories", (options) =>
  cy.app("factory_bot", options).then((records) => {
    options.forEach(([, factory], index) => {
      createdRecords[factory] = createdRecords[factory] || [];
      createdRecords[factory].push(records[index]);
    });
  })
);

Cypress.Commands.add("appFixtures", (options) => {
  cy.app("activerecord_fixtures", options);
});
// CypressOnRails: end

const reset = () => {
  createdRecords = {};
  cy.app("clean");
  cy.appEval("ActionMailer::Base.deliveries.clear");
};

beforeEach(() => {
  reset();
});

Cypress.on("after:run", () => {
  reset();
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
