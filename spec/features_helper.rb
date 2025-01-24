# frozen_string_literal: true

require "capybara"
require "capybara/rspec"
require "capybara/cuprite"
require "axe-rspec"
require "site_prism"
require "site_prism/all_there" # Optional but needed to perform more complex matching

Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  options = {
    window_size: [1400, 1400],
    timeout: 20,
  }

  Capybara::Cuprite::Driver.new(app, options)
end

Capybara.server_port = 9887 + ENV["TEST_ENV_NUMBER"].to_i
Capybara.automatic_label_click = true

RSpec.configure do |config|
  config.include AxeHelper, type: :feature
  config.include FeatureFlagHelper, type: :feature
  config.include InteractionHelper, type: :feature
  config.include PageAssertionsHelper, type: :feature
  config.include UserHelper, type: :feature

  config.include Steps::GenericPageObjectSteps, type: :feature

  # need this for axe
  config.before(:each, type: :feature) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
