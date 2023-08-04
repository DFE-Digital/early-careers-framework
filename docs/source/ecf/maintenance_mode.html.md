---
title: Maintenance mode
weight: 4
---

# Maintenance mode

The repo includes a simple service unavailable page page that can be pushed to a cf app.  Traffic can be rerouted to it instead of the main application. This is handy in case of a critical bug being discovered where we need to take the service offline, or in case of maintenance where we want to avoid users interacting with the service.

When enabled, all requests will receive the [service unavailable page](/service_unavailable_page/web/public/internal/index.html).

## Upcoming Maintenance Warnings

The ECF app features an upcoming maintenance banner that can be enabled by setting the constants in app/components/banners/maintenance_component.rb.

## Enable Maintenance mode

Login to PaaS: `cf login --sso` or `cf login -o dfe -u my.name@digital.education.gov.uk`

### Production

Run the make command: `make prod enable-maintenance APP_NAME=ecf-production CONFIRM_PRODUCTION=y`

To bring the application back up: `make prod disable-maintenance APP_NAME=ecf-production CONFIRM_PRODUCTION=y`

### Sandbox

Run the make command: `make sandbox enable-maintenance APP_NAME=ecf-sandbox`

To bring the application back up: `make sandbox disable-maintenance APP_NAME=ecf-sandbox`

### Staging

Run the make command: `make staging enable-maintenance APP_NAME=ecf-staging`

To bring the application back up: `make staging disable-maintenance APP_NAME=ecf-staging`

### Review Apps

Review apps need their PR number specifying, for PR 3766 see below.

Run the make command: `make review_aks enable-maintenance APP_NAME=ecf-review-pr-3766 PULL_REQUEST_NUMBER=3766`

To bring the application back up: `make review_aks disable-maintenance APP_NAME=ecf-review-pr-3766 PULL_REQUEST_NUMBER=3766`
