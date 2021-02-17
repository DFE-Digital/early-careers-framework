![Tests](https://github.com/DFE-Digital/early-careers-framework/workflows/Test/badge.svg)

# Early careers framework

## Prerequisites

- Ruby 2.7.1
- PostgreSQL
- NodeJS 12.13.x
- Yarn 1.12.x
- Docker

## Setting up the app in development

### Without docker

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Create `.env` file - copy `.env.template`. Set your database password and user in the `.env` file
4. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data
5. Run `bundle exec rails server` to launch the app on http://localhost:3000
6. Run `./bin/webpack-dev-server` in a separate shell for faster compilation of assets

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
Generate an api key for yourself and set it in your `.env` file.

### Set up git hooks
Run `git config core.hooksPath .githooks` to use the included git hooks.

## Whats included in this boilerplate?

- Rails 6.0 with Webpacker
- [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend)
- RSpec
- Dotenv (managing environment variables)
- Travis with Heroku deployment

## Running specs, linter(without auto correct) and annotate models and serializers
```
bundle exec rake
```

## Running specs
```
bundle exec rspec
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec rubocop app config db lib spec Gemfile --format clang -a

or

bundle exec scss-lint app/webpacker/styles
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

### Prerequisites

- Your department, agency or team has a GOV.UK PaaS account
- You have a personal account granted by your organisation manager
- You have downloaded and installed the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads) for your platform

### Deploy

1. Run `cf login -a api.london.cloud.service.gov.uk -u USERNAME`, `USERNAME` is your personal GOV.UK PaaS account email address
2. Run `bundle package --all` to vendor ruby dependencies
3. Run `yarn` to vendor node dependencies
4. Run `bundle exec rails webpacker:compile` to compile assets
5. Run `cf push` to push the app to Cloud Foundry Application Runtime

Check the file `manifest.yml` for customisation of name (you may need to change it as there could be a conflict on that name), buildpacks and eventual services (PostgreSQL needs to be [set up](https://docs.cloud.service.gov.uk/deploying_services/postgresql/)).

The app should be available at https://govuk-rails-boilerplate.london.cloudapps.digital

## Dealing with cip content

### Seeding cip content / anything else

1. Make sure you are ok with the content in seed files to be created in your db.
2. Run `cf login -a api.london.cloud.service.gov.uk -u USERNAME`, `USERNAME` is your personal GOV.UK PaaS account email address
3. Run `cf run-task ecf-dev "cd .. && cd app && ../usr/local/bundle/bin/bundle exec rails db:seed"` to start the task.

### Updating cip content from changes on an app

1. Download the file to your machine - log in as admin, go to cip page, press the button to download content.
1. Copy the file or its contents into `cip_seed.rb`.
1. Add an option `on_duplicate_key_ignore` to lead providers, think carefully which ones from seed dump are needed.
1. Commit, push, run seeding job from above in the deployed app.

