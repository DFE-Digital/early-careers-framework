import { Given } from "cypress-cucumber-preprocessor/steps";
import OnRails from "../on-rails";

// eslint-disable-next-line import/prefer-default-export
export const parseArgs = (argsString) => {
  const args = {};
  argsString.split(/ and |, /).forEach((argString) => {
    if (argString.split(" ").includes("created")) {
      const matches = /created ([^ ]+)(?: as ([^ ]+))?/.exec(argString);
      const factory = matches[1];
      const as = matches[2] || factory;

      args[`${as}_id`] = OnRails.getCreatedRecord(factory).id;
    } else {
      const [, key, value] = /([^ ]+) "([^"]+)"/.exec(argString);
      args[key] = value;
    }
  });

  return args;
};

expect(parseArgs('start_year "2021"')).to.deep.equal({ start_year: "2021" });
expect(parseArgs('a "a b" and b "b c"')).to.deep.equal({ a: "a b", b: "b c" });
expect(parseArgs('a "a b", b "b" and c "d"')).to.deep.equal({
  a: "a b",
  b: "b",
  c: "d",
});

Given("{word} was created", (factory) => {
  cy.appFactories([["create", factory]]);
});

Given("{word} was created as {string}", (factory, traits) => {
  cy.appFactories([["create", factory, ...traits.split(", ")]]);
});

Given("{word} was created with {}", (factory, args) => {
  cy.appFactories([["create", factory, parseArgs(args)]]);
});

Given("{word} was created as {string} with {}", (factory, traits, args) => {
  cy.appFactories([
    ["create", factory, ...traits.split(", "), parseArgs(args)],
  ]);
});

const login = (traits, args) => {
  const factoryArgs = ["create", "user", ...traits.split(", ")];

  if (args) {
    factoryArgs.push(parseArgs(args));
  }

  cy.appFactories([factoryArgs])
    .as("userData")
    .then(([user]) => {
      cy.visit(`/users/confirm_sign_in?login_token=${user.login_token}`);
    });

  cy.get(".govuk-main-wrapper .govuk-button").contains("Continue").click();
};

Given("I am logged in as {string}", (traits) => login(traits));
Given("I am logged in as {string} with {}", (traits, args) =>
  login(traits, args)
);

Given("I am logged in as existing user with {}", (argsStr) => {
  const args = parseArgs(argsStr);

  const argsStrRails = Object.entries(args)
    .map(([key, value]) => `${key}: "${value}"`)
    .join(", ");

  cy.appEval(
    `User.find_by(${argsStrRails}).update(
      login_token: "abcdefghij",
      login_token_valid_until: 12.hours.from_now)`
  );
  cy.visit(`/users/confirm_sign_in?login_token=abcdefghij`);

  cy.get(".govuk-main-wrapper .govuk-button").contains("Continue").click();
});

const setFeature = (feature, isActive) => {
  cy.appEval(
    `Feature.find_or_create_by(name: "${feature}").update!(active: ${isActive})`
  );
};

Given("feature {word} is active", (feature) => setFeature(feature, true));
Given("feature {word} is not active", (feature) => setFeature(feature, false));
