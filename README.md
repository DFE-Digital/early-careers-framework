![Tests](https://github.com/DFE-Digital/early-careers-framework/workflows/Test/badge.svg)

# Early careers framework

## Development Setup

### Prerequisites

- Ruby 3.2.6
- PostgreSQL (we deploy on 11.x)
- NodeJS 18.18.0
- Yarn 1.12.x
- Docker
- Redis 6.2

### Without docker

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Create `.env` file - copy `.env.template`. Set your database password and user in the `.env` file
4. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data
6. Run `./bin/dev` to launch the app on http://localhost:3000, sidekiq and auto-compile assets. To run with a Sidekiq worker enabled run `./bin/dev -j`
7. For most work, you will need to seed the database with `rails db:seed`. For school data, see [Importing School data](#importing-school-data)

### With docker

There is a separate Dockerfile for local development. It isn't (currently) very
widely used - if it doesn't work, make sure any recently changes to Dockerfile
have been applied to Dockerfile.dev where appropriate.

1. Create `.env` file - copy `.env.template`. Set your database password and user from the docker-compose file in the `.env` file
2. Run `docker-compose build` to build the web image
3. Run `docker-compose run --rm web bundle exec rake db:setup` to setup the database
4. Run `docker-compose up` to start the service

It should be possible to run just the database from docker, if you want to.
Check docker-compose file for username and password to put in your `.env` file.

If you want to seed the database you can either run `db:drop` and `db:setup` tasks with your preferred method,
or `db:seed`.

### Building the documentation

The API documenation is a [Middleman](https://middlemanapp.com/) app contained in the `docs` directory. In production it's
built at deploy time and available at [/api-reference](https://manage-training-for-early-career-teachers.education.gov.uk/api-reference). We can't use `middleman serve` because
the Middleman application assumes it's embedded and references the Rails application's assets, so instead we need to
build it using the following steps:

1. install [entr](https://github.com/eradman/entr) using your package manager of choice (eg. `brew install entr`)
2. use the Makefile to keep building the documentation whenever a file is changed `make -C docs` or `cd docs && make watch`

### Govuk Notify

Register on [GOV.UK Notify](https://www.notifications.service.gov.uk).
Ask someone from the team to add you to our service.
Generate a limited api key for yourself and set it in your `.env` file.

## Running specs, linter(without auto correct) and annotate models and serializers

```
bundle exec rake
```

## Running specs

```
bundle exec rspec
```

## Running specs in parallel

### One time Setup
```
bundle exec rake parallel:create
```

### Running specs thereafter
```
bundle exec rake parallel:migrate
bundle exec rake parallel:spec
```

## Running swagger doc generator

It auto-generates swagger/*/api_spec.json from the schema files located in spec/docs

```bash
bundle exec rake rswag:specs:swaggerize
```

## Importing swagger JSON spec into Postman

To import the JSON spec into Postman (or equivalent) copy from:

```
https://github.com/DFE-Digital/early-careers-framework/blob/develop/swagger/v1/api_spec.json
```

Ideally change baseUrl to http://localhost:3000, since sandbox is used for testing. A bearer token is required per request and should be created in each respective environment e.g. development, sandbox

## End to End Scenario testing

We use Capybara for end-to-end tests. These can be found in the [scenarios folder within ./spec/features/](./spec/features/scenarios).

The E2E scenarios currently covered are:

  1. Transferring a participant to a new School
  2. Onboarding a withdraw participant to a new School

Scenarios tests use the `:end_to_end_scenario` tag so that they get excluded from the standard rspec command

For more information on how we now write feature scenarios please our [feature testing documentation](./documentation/feature_testing.md)

### Setup

```
RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load
```

To run the complete set of scenario tests use either:

```
bundle exec bin/scenarios_ci
```

or

```
bundle exec bin/scenarios_ci --fail-fast
```

To run a specific scenario test include the environment variable `SCENARIOS`, for example to run scenarios 2, 12 and 20 use:

```
SCENARIOS=2,12,20 bundle exec bin/scenarios_ci
```

Please note: `--fail-fast` is recommended when running scenarios locally due to the length of time they can all take to run.


## Smoke tests

We run smoke tests against review apps. After a review app is deployed, a smoke test will be run against it automatically.

Tests are written in rspec, so if you need to debug them, you can run them locally - just make sure to set the domain to the review app you want to debug against.

## Review apps
Review apps are automatically created when a PR is opened. A link to the app will be posted on the review.

The database of the review app will be truncated and reseeded on each commit and subsequent deploy.
This is to aid in manual testing using scenarios set up using seeds.

### Magic birthdates
To further aid manual testing and review of certain circumstances and behaviours, there are a number of magic values
that can be used in the __date of birth__ field when adding or validating an ECT or mentor participant. Using these values
returns a "spoofed" response from the DQT API integration that enables us to proceed without calling the API or needing to know
exactly what and how their test data is configured. These magic values are only available in development environments.

| Date of birth | Validation response |
|---------------|---------------------|
| 1/1/1900 | All data matches and eligible participants |
| 2/1/1900 | Participant found but the Name and NiNo do not match |
| 3/1/1900 | No match found |
| 4/1/1900 | Participant matched but no QTS date recorded |
| 5/1/1900 | Participant matched but no induction recorded |
| 6/1/1900 | Participant matched but active alerts present |
| 21/1/1900 | Participant matched and has a 2021 cohort induction start date |
| 22/1/1900 | Participant matched and has a 2022 cohort induction start date |
| 23/1/1900 | Participant matched and has a 2023 cohort induction start date |
| 24/1/1900 | Participant matched and has a 2024 cohort induction start date |
| 25/1/1900 | Participant matched and has a 2025 cohort induction start date |

## Deployment infrastructure

- review, which has `RAILS_ENV=review`
- [staging](https://st.manage-training-for-early-career-teachers.education.gov.uk/), which has `RAILS_ENV=staging`, [internal url](https://cpd-ecf-staging-web.test.teacherservices.cloud/)
- [sandbox](https://sb.manage-training-for-early-career-teachers.education.gov.uk/), which has `RAILS_ENV=sandbox`, [internal url](https://cpd-ecf-sandbox-web.teacherservices.cloud/)
- [production](https://manage-training-for-early-career-teachers.education.gov.uk/), which has `RAILS_ENV=production`, [internal url](https://cpd-ecf-production-web.teacherservices.cloud/)

These are deployed using terraform. See the documentation for [details on terraform](./documentation/terraform.md) and [debugging in deployed environments](./documentation/debugging_in_govpaas.md).

In addition to a web app, some environments have a worker app for running background jobs. For details, see the terraform code.

The `/healthcheck` endpoint on each deployed app will give details on things like version number, commit SHA, background jobs, and database migrations.

### Creating an initial admin user
1. Follow the [debugging instructions](./documentation/debugging_in_govpaas.md) to gain SSH access to the instance and cd to the app dir
2. Run `/usr/local/bin/bundle exec rake "admin:create[user name,email@example.com]"`. For example, the command for a user named `John Smith` with the email
`john.smith@example.com` would be `/usr/local/bin/bundle exec rake "admin:create[John Smith,john.smith@example.com]"`.

**The format here is important!
   Notice that there are no extra spaces in the square brackets, and no quote marks inside the square brackets**

## Importing School data
1. Make sure you have copied `.env.template` to `.env` and filled in the GIAS information with details from a teammate
2. Run `bundle exec rake schools_data:import` to import the latest schools data from GIAS. This takes around 10 minutes
3. Run `bundle exec rake sparsity:import` to populate the sparsity tables
4. Run `bundle exec rake pupil_premium:import` to populate the pupil premium tables

Note: running `db:seed` schedules the `schools_data:import` as a background. You can run `bundle exe sidekiq` to execute this in the background.

## Resetting the database on a dev environment

Much like review apps, the dev database is truncated and reseeded on every merge to develop.

If the database needs to be reset for testing, there is a github action for this called `Run task in dev space`.
The default parameters will reset the dev database. This action can also be used to run a rake task on dev or any review app.

## Running background jobs locally

Background jobs are run using sidekiq, which relies on redis. You will need to install redis and run it using:
```
redis-server
```
This should run on `*:6379`, which sidekiq will expect outside of
cloudfoundry.

And start sidekiq running using:
```
bin/sidekiq
```

## Sending emails

We use [Gov.UK Notify](https://www.notifications.service.gov.uk/) to send emails.

### Mailshots to schools
We have a variety of emails that we send to schools on a regular basis. This are currently triggered manually, via rake task.
The rake tasks are defined in [schools.rake](./lib/tasks/schools.rake), for example:

```bash
bundle exec rake 'schools:send_invites[urn1 urn2 ...]'
```

## Generating API access tokens for lead providers

```bash
bundle exec rake lead_provider:generate_token "name or id"
```

## Run payment calculator for a given lead provider with an optional number of participants (default is 2,000) to generate the payment breakdown

```bash
bundle exec rake payment_calculation:breakdown "<name or id>" "<number of participants>"
```

Where `"name or id"` is a name or id from the `lead_providers` table.

## Generating a token for E&L api
1. Get into Rails console for the environment you want to generate the token for.
2. Run `EngageAndLearnApiToken.create_with_random_token!`
3. Rails console should output a string, that's your unhashed token, you can keep it and use it to access E&L endpoints.

### Feature Flags

Certain aspects of app behaviour are governed by a minimal implementation of feature flags. Feature flag states are persisted in the database with a name and an active state. To activate a new feature you can run `Feature.create!(name: 'rate_limiting', active: true)`.

The available flags are listed in `app/services/feature_flag.rb`, and available in the constant `FeatureFlag::FEATURES`. Each one is tested with a dedicated spec in `spec/features/feature_flags/`.

## payment_calculator

The code in[`lib/payment_calculator/ecf/`](lib/payment_calculator/ecf/)performs payment calculations for [ECFs (Early Career Framework)](https://www.early-career-framework.education.gov.uk/) using commercial information so that training providers can be paid the correct amount.

The calculator can generate each intermediary step in the calculation so that any questions over how the final totals were reached can be answered by interested parties.

Output from `PaymentCalculation.new(contract: <ContractObject>)` will instantiate a calculator for that specific contract. This can then be called, passing in the retention event type, and total number of participants to calculate for. (There is also a class level call shortcut for this.) which means that for a one off calculation you can call `PaymentCalculation.new(contract: <ContractObject>).call(event_type:, total_participants:)`, or `PaymentCalculation.call({contract: <ContractObject>}, event_type:, total_participants:)`. (Note the brackets around the first hash. In this call format, that is what determines what is passed to the initializer and what goes to the call.)

### Payment entity naming

Here are the names we are using in the code and specs for the different concepts involved in the calculations by way of an example:

> Per participant price £995 >>
per participant service fee £398 (40%) >> monthly service fee £27k >> total service fee £796k
>
> Per participant price £995 >> per participant output payment £597 (60%) >> per participant output payment for a retention period £119 (20% (or 15% depending on the period) of 60%) >> output payment total for the retention period with 1900 retained participants £226k

* "Participants" includes both teachers and mentors.
* "Output payments" are payments made based on the performance of the training provider (i.e. their output).
* "Payment type" for start/retention_x/completion output payments.

## Storing reasons in PaperTrail
Sometimes, we need to make manual changes to data. The reason for this change may not be obvious to those looking in the future.
We version changes using PaperTrail, and when making an unusual change, we can set a reason to help those reading the change history.

To set a reason for an entire console session:

`PaperTrail.request.controller_info = {reason: "some reason"}`

To set a reason for a block:

```
PaperTrail.request(controller_info: {reason: "some reason"}) do
  # do something
end
```
## Monitoring, logging, and alerting
### Sentry
We use [sentry.io](https://sentry.io/) for error tracking and performance monitoring. Ask a team member for access - this is done through digi-tools.
### Statuscake
We use statuscake for uptime monitoring. Ask a team member for access - this is done with a service now ticket.

## Documentation
We use a gem called `tech_docs_template` to generate govuk-style documentation. It is heavily inspired by Teacher Training API.

You can find it, with its readme, in `docs` directory.

The project in `docs` directory can be used to generate a static site, which we put in `public/api-reference` to make our app serve it.
