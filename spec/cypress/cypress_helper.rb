# frozen_string_literal: true

# This is loaded once before the first command is executed

require "factory_bot_rails"
require "cypress_on_rails/smart_factory_wrapper"

CypressOnRails::SmartFactoryWrapper.configure(
  always_reload: !Rails.configuration.cache_classes,
  factory: FactoryBot,
  files: [
    Rails.root.join("spec/factories.rb"),
    Rails.root.join("spec/factories/**/*.rb"),
  ],
)
