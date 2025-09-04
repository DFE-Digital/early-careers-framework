# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Because these paths are searched in order, we want the assets to come first
# Add the GOVUK Frontend images path
Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets")

Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/images")

# Add the GOVUK Frontend fonts path
Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/fonts")

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")
