# frozen_string_literal: true

require "capybara"
require "capybara/rspec"
require "axe-rspec"
require "selenium-webdriver"
require "site_prism"
require "site_prism/all_there" # Optional but needed to perform more complex matching

Capybara.register_driver :headless_firefox do |app|
  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120

  options = Selenium::WebDriver::Firefox::Options.new
  options.args << "--headless" unless ENV["NOT_HEADLESS"]
  options.args << "--width=1400"
  options.args << "--height=1400"

  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    options:,
    http_client:,
  )
end

Capybara.server_port = 9887 + ENV["TEST_ENV_NUMBER"].to_i
Capybara.javascript_driver = :headless_firefox
Capybara.automatic_label_click = true
Capybara.default_max_wait_time = 10

# Silence deprecation warnings until upstream Capybara version is updated https://github.com/teamcapybara/capybara/issues/2779
Selenium::WebDriver.logger.ignore(:clear_local_storage, :clear_session_storage)

RSpec.configure do |config|
  config.include AxeHelper, type: :feature
  config.include FeatureFlagHelper, type: :feature
  config.include InteractionHelper, type: :feature
  config.include PageAssertionsHelper, type: :feature
  config.include UserHelper, type: :feature

  config.include Steps::GenericPageObjectSteps, type: :feature

  config.before(:each, type: :feature) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
