import { Given } from "cypress-cucumber-preprocessor/steps";

const parseArgs = (argsString) => {
  const args = {};
  argsString.split(/ and |, /).forEach((argString) => {
    const [, key, value] = /([^ ]+) "([^"]+)"/.exec(argString);
    args[key] = value;
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

Given("{word} was created as {string} with {}", (factory, traits, args) => {
  cy.appFactories([
    ["create", factory, ...traits.split(", "), parseArgs(args)],
  ]);
});

Given("{word} was created with {}", (factory, args) => {
  cy.appFactories([["create", factory, parseArgs(args)]]);
});
