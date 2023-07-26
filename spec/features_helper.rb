# frozen_string_literal: true

require "capybara"
require "capybara/rspec"
require "axe-rspec"
require "webdrivers/chromedriver"
require "site_prism"
require "site_prism/all_there" # Optional but needed to perform more complex matching

Capybara.register_driver :chrome_headless do |app|
  args = %w[disable-build-check disable-dev-shm-usage no-sandbox window-size=1400,1400]
  args << "headless" unless ENV["NOT_HEADLESS"]

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: Selenium::WebDriver::Options.chrome(args:),
  )
end

# This is required as per https://github.com/titusfortner/webdrivers/issues/247
# and can be removed when selenium 4.11 is released
Webdrivers::Chromedriver.required_version = "114.0.5735.90"

Capybara.server_port = 9887 + ENV["TEST_ENV_NUMBER"].to_i
Capybara.javascript_driver = :chrome_headless
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
    WebMock.disable_net_connect!(allow_localhost: true,
                                 allow: "chromedriver.storage.googleapis.com")
  end
end
