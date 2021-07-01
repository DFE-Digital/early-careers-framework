## Cypress + cucumber setup

The integration tests in this repository are written using Gherkin syntax and
powered by the following technologies:

- [Cypress]
- [CypressOnRails]
- [cypress-cucumber-preprocessor]

The idea behind these tests was to test features and user journeys to avoid
repetitive manual testing, and write them in a way that was understandable (and
therefore approvable) by non-technical stakeholders such as project owners.

### How to write integration tests

Feature specs are located in `spec/cypress/integration/` and have a `.feature`
extension. They're written using [Gherkin syntax] and the step definitions are
defined in `spec/cypress/support/step_definitions/`. For the most part, you
shouldn't need to define your own step definitions as the existing ones are
designed to be reusable.

#### Navigation

Most step definitions you need for navigation can already be found in
`common-navigation.js`. Add your path to the `pagePaths` object and then you'll
be able to use it with most of the step definitions in that file, e.g.

- `Given I am on "dashboard" page`
- `When I navigate to "dashboard" page` (to simulate user manually changing URL)
- `Then I should be on "dashboard" page`

#### Interaction

Interacting with the page follows a similar principle to navigation: add your
selector to an object at the top of `common-interaction.js` and most of the
step definitions in that file will be usable, e.g.:

- `When I click on "change school link"`
- `When I type "Bob" into field labelled "First name"`
- `Then "page heading" should have value "Teacher: Bob"`

#### Database

We use [cypress-cucumber-preprocessor] to let us talk to factory_bot from our
specs to set up simple state. E.g.:

- `Given cohort was created with start_year "2021"`
- `Given user was created as "admin" with email "admin@example.com"` (where
  `admin` is the name of a trait).

See the "Initialising database state" section below for more information on
when this should and shouldn't be used.

### Conventions

#### Step definitions

Nearly all of our existing step definitions that can be from the point of view
of the user - e.g. what they do or what they should see - are in present tense,
using active voice, and first-person.

E.g.:

- `Given I am on "index" page`
- `When I click on "navigation link" containing "Dashboard"`
- `Then I should be on "dashboard" page"`

Exceptions are for steps that aren't from the point of the user, such as:

- `Given scenario "user_cip" has been run`
- `Then the page should be accessible`
- `Then percy should be sent snapshot`

#### Reuse step definitions where possible

Most of the time, you won't need to write new step definitions as the existing
ones are designed to be reusable by passing arguments into the steps: e.g.
instead of `I click on user delete button` you can write `I click on "user
delete" button` or `I click on "button" containing "delete user"` after adding
the element to the objects in common-interaction.js.

You should also consider this when writing new step definitions - make them as
reusable as possible so that other people don't have to write similar step
definitions in the future.

#### Best practices

[Cypress best practices] and Cucumber best practices sometimes conflict - e.g.
Cucumber specs are supposed to be as small as possible and only test one thing
while Cypress best practice is to test an entire user journey in one test as
spinning up a browser and initialising the database can have a fairly
significant overhead. It's good to be aware of both of them!

#### Initialising database state

For setting up simple data, the step definitions in `database.js` usually
suffice, e.g.:

- `Given cohort was created with start_year "2021"`

For more complicated data, including pretty much anything relational, you'll
want to use a scenario file instead. Create your scenario file (e.g. 
`test_scenario.rb`) in `spec/cypress/app_commands/scenarios/` and use the
following in your spec:

- `Given scenario "test_scenario" has been run`

#### Visual and accessibility testing

We use [Percy] for visual testing and [cypress-axe] for basic automated
accessibility testing. Every time you add a test for a new page (or significant
state change to an existing page), add the following lines to your spec:

```
Then the page should be accessible
And percy should be sent snapshot
```

Note that percy snapshot names should be unique. By default they take the name
of the feature + scenario, but if you have more than one percy snapshot in the
same test you'll need to give it a name manually:

```
And percy should be sent snapshot called "page name"
```

[Cypress]: https://docs.cypress.io/guides/overview/why-cypress
[CypressOnRails]: https://github.com/TheBrainFamily/cypress-cucumber-preprocessor
[cypress-cucumber-preprocessor]: https://github.com/TheBrainFamily/cypress-cucumber-preprocessor
[Gherkin syntax]: https://cucumber.io/docs/gherkin/reference/
[Cypress best practices]: https://docs.cypress.io/guides/references/best-practices
[Percy]: https://percy.io/
[cypress-axe]: https://github.com/component-driven/cypress-axe
