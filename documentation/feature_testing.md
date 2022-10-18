# Feature test setup

The feature tests in this repository are written using the following gems:

- [Capybara]
- [Page objects]
- [Chromedriver]
- [Axe]

The feature tests are used to test service features and user journeys to avoid
repetitive manual testing. They use Given-When-Then syntax so that they
are, hopefully understandable (and therefore approvable) by non-technical
team members such as analysts, product owners and service owners as well as
external stakeholders.

## How to write feature tests

Feature tests are located in the `spec/features/` folder and have a `_spec.rb`
extension. They're written using Given-When-Then syntax and the step definitions
are defined in `spec/support/features/steps`. Step definitions are designed to
be reusable so hopefully there will be little need to define your own.

### Page Objects

Every page is described by a [Page object] located in the
`spec/support/features/pages` folder and have a `_page.rb` or `_wizard.rb`
extension. Page objects provide helpers for navigating from the page,
interacting with form elements on the page, checking the content of the page
and verifying that the expected page has loaded correctly.

Each page object inherits from `::Pages::BasePage` as in this example of the
Privacy Policy page object;

```ruby
module Pages
  class PrivacyPolicyPage < ::Pages::BasePage
    set_url "/privacy-policy"
    set_primary_heading "Privacy policy"
  end
end
```

A page object needs to include the following at least;

- `set_url` should be set to the url of the page on load
- `set_primary_heading` should be set to the text contents of the pages `H1` heading

#### Navigation

Navigation methods should use the Capybara action `click_on "Link text"` to interact with
clickable text within the page and then should call the static `loaded`
method of the expected pages object to confirm that the correct page has loaded.

Navigation method names should describe the task to be performed by the
navigation and should not specifically try to use the actual text of the
navigation link although this may end up being the case for some links;

```ruby
def view_privacy_policy
  click_on "Privacy"

  Pages::PrivacyPolicyPage.loaded
end
```

The full feature scenario suite should prove that a user can achieve any
desired tasks and so at least one scenario should navigate the user from the
start page to the appropriate page that the task is required to be performed
on. If this navigation is already present then it is possible to use the page
objects to directly load a specific page, as in;

```ruby
Pages::CheckAccountPage.load
```

Again the Primary Heading will be checked once the page has been loaded but as
the URL is loaded directly this check is not performed.

#### Interaction

Interaction with the page to fill in form fields and click buttons to submit
that information to the server are also handled with page object methods named
to describe the task.

A page interaction will generally be more than just a single page action such
as in the case of a `find` action which will require a value to be entered into
a form and a button to be clicked in order to submit the query to the server.

```ruby
def find(participant_name)
  user_id = User.find_by(full_name: participant_name).id

  fill_in "Search records", with: user_id
  click_on "Search"

  Pages::FinanceParticipantDrilldown.loaded
end
```

When filling in fields or selecting/choosing field values we should use the
appropriate label text rather than the HTML element via CSS selectors as this
is what a user would be doing.

#### Expectations

Every feature scenario should include a way of proving that the user is able to
understand that the task has been performed correctly. The easiest way to check
this is to achieve this is to assert that the page is displaying the expect text
or information.

Several helper methods are included on the `BasePage` class to help describe any
failing expectation better;

- `element_visible?(element)`
- `element_hidden?(element)`
- `element_has_content?(element, expected_content)`
- `element_without_content?(element, unexpected_content)`

These can be used as follows;

```ruby
def confirm_will_use_dfe_funded_training_provider
  element_has_content? self, "Programme Use a training provider funded by the DfE"
end
```

In this case if the exact content is not found within the page then the
scenario will fail with an explanation of the expectations;

```bash
expected to find "Programme Use a training provider funded by the DfE" within
===
Manage your training
Induction tutor New SIT
View your early career teacher and mentor details
Lead Provider
Delviery Partner
Programme DfE-accredited materials
report that your school has been confirmed incorrectly
===
```

### Steps

Each feature scenario is made up of a series of steps which call the methods of
the page objects to ensure consistent interaction across the suite. Some specific
steps may have to defined within the scenario feature itself and should be set as
`private` to ensure they are not accidentally picked up by another scenario.

If a scenario step method is intended to be shared between multiple scenarios
then it should be defined within the `spec/support/features/steps` folder in a
file with the extension `_steps.rb`.

Hopefully most of the steps within a scenario will be covered by the generic
step helpers which are already defined within the steps files.

#### Loading a page

To use the generic navigation steps you will need to have a page object that
describes the page you are currently expected to navigate from. The templates for
this sort of step are;

```handlebars
given_i_am_on_the_{{page_object}}

when_i_am_on_the_{{page_object}}_with_{{query_params}}
```

These templated steps will use a specific page object to load its url where `page_object` is
constantized. If it includes `query_params` then this string is parsed, split
on `_and_` and the arguments passed to `PageObject#load` so;

```handlebars
given_i_am_on_the_school_participant_dashboard_page_with_participant_id
"ABC-9876"
```

is interpreted as;

```ruby
::Pages::SchoolParticipantDashboardPage.load(participant_id: "ABC-9876")
```

#### Validating that a page has loaded

It is also possible to validate that the correct page is now loaded using two
similar templated steps;

```handlebars
then_i_am_on_the_{{page_object}}

and_i_am_on_the_{{page_object}}_with_{{query_params}}
```

In these templated steps a specific page object is used to check the page has
loaded where `page_object` is constantized. Agian, if it includes `query_params`
then this string is parsed, split on `_and_` and the arguments passed to
`PageObject#loaded` so;

```handlebars
then_i_am_on_the_school_participant_dashboard_page_with_participant_id "1234ZYX"
```

is interpreted as;

```ruby
::Pages::SchoolParticipantDashboardPage.loaded(participant_id: "1234ZYX")
```

#### interacting with a page

To use the generic interaction steps you will need to have a page object that
describes the page you are currently expected to interact with. Examples of
the templates for this sort of step are;

```handlebars
given_i_{{method_name}}_on_{{page_object}}

when_i_{{method_name}}_from_{{page_object}}_with_{{query_params}}

then_i_{{method_name}}_on_{{page_object}}

and_i_{{method_name}}_from_{{page_object}}_with_{{query_params}}
```

These will call a specific action of a specific page object where `method_name`
and `page_object` are constantized. If it includes `query_params` then this
string is parsed, split on `_and_` and the arguments passed to
`PageObject#method_name` so;

```handlebars
given_i_find_a_participant_from_school_participant_dashboard_page_with_participant_name
"The Participant"
```

is interpreted as;

```ruby
::Pages::SchoolParticipantDashboardPage.find_a_particiapnt(participant_name: "The Participant")
```

### Conventions

#### Step definitions

Steps should describe the scenario from the point of view of the user - e.g.
what they do or what they should see - the language should be in present tense,
using active voice and first-person. for example;

- `given_i_am_on_the_school_dashboard_page`
- `when_i_view_participants_from_the_school_dashboard_page`
- `then_i_am_on_the_school_particiapnt_dashboard_page`

Exceptions are for steps that aren't from the point of the user, such as:

- `and_the_page_is_accessible`

The language of steps should be definite rather than speculative, so `Then I am on`
rather than `Then I should be on`.

#### Reuse step definitions where possible

Most of the time, you won't need to write specific step definitions as the
page objects should encapsulate all the steps needed to achieve a task.
instead of `I click on "delete" button` you can write `I delete user "The Participant"` and
this will encapsulate all the actions needed to delete the user named
"The Participant" and notify us of any action that fails during this task.

You must consider this when writing new step definitions - make them as
reusable as possible so that other people don't have to write similar step
definitions in the future.

#### Setting up a scenario

#### Accessibility testing

We use [Axe] for basic automated
accessibility testing. Every time you add a test for a new page (or significant
state change to an existing page), add the following lines to your spec:

```
then_the_page_is_accessible
```

[capybara]: http://teamcapybara.github.io/capybara/
[chromedriver]: https://github.com/titusfortner/webdrivers
[axe]: https://www.deque.com/axe/
[capybara cheatsheet]: https://devhints.io/capybara
[page objects]: https://github.com/site-prism/site_prism
