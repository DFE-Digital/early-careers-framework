![Tests](https://github.com/DFE-Digital/early-careers-framework/workflows/Test/badge.svg)

# Early careers framework [TEST BRANCH]

## Prerequisites

- Ruby 2.7.2
- PostgreSQL
- NodeJS 14.16.0
- Yarn 1.12.x
- Docker

## Setting up the app in development

We have a requirement for commits to be signed: https://docs.github.com/en/github/authenticating-to-github/signing-commits

### Without docker

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Create `.env` file - copy `.env.template`. Set your database password and user in the `.env` file
4. Run `mkdir log && touch log/mail.log`
5. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data
6. Run `bundle exec rails server` to launch the app on http://localhost:3000
7. Run `./bin/webpack-dev-server` in a separate shell for faster compilation of assets

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

### Govuk Notify
Register on [GOV.UK Notify](https://www.notifications.service.gov.uk).
Ask someone from the team to add you to our service.
Generate a limited api key for yourself and set it in your `.env` file.

### Set up git hooks
Run `git config core.hooksPath .githooks` to use the included git hooks.

## Running specs, linter(without auto correct) and annotate models and serializers
```
bundle exec rake
```

## Running specs
```
bundle exec rspec
```

## Running swagger doc generator

It auto-generates swagger/*/api_spec.json from the schema files located in spec/docs

```bash
bundle exec rake rswag
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec rake lint:ruby
```

## End to end tests

To set up:

```
RAILS_ENV=test bin/rake db:create db:schema:load
```

Then in separate windows:

```
bin/rails server -e test -p 5017
```

```
yarn cypress:open
```

## Review apps
Review apps are automatically created when a PR is opened. A link to the app will be posted on the review.

## Deploying on GOV.UK PaaS
Check the [documentation](./documentation/terraform.md) for detailed information on terraform.

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

Note: running `db:seed` schedules the `schools_data:import` as a delayed job. You can run `bin/delayed_job start --exit-on-complete`
to execute this delayed job in the background.

## Resetting the database on a dev environment

1. Make sure you are ok with the content in seed files to be created in your db.
2. Run `cf login -a api.london.cloud.service.gov.uk -u USERNAME`, `USERNAME` is your personal GOV.UK PaaS account email address
3. Run `cf run-task ecf-dev "cd .. && cd app && ../usr/local/bundle/bin/bundle exec rails db:safe_reset"` to start the task.

## Sending school nomination invites

```bash
bundle exec rake 'schools:send_invites[urn1 urn2 ...]'
```
