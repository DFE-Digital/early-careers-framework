# frozen_string_literal: true

require "capybara"
require "capybara/rspec"
require "axe-rspec"
require "selenium-webdriver"
require "site_prism"
require "site_prism/all_there" # Optional but needed to perform more complex matching

Capybara.register_driver :chrome_headless do |app|
  args = %w[disable-build-check disable-dev-shm-usage disable-gpu no-sandbox window-size=1400,1400 enable-features=NetworkService,NetworkServiceInProcess disable-features=VizDisplayCompositor]
  args << "headless" unless ENV["NOT_HEADLESS"]

  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120

  # Pin Chrome version due a possible race condition between newer versions of chromedriver and selenium
  # causing some specs to fail intermittently on CI with the failure Net::ReadTimeout
  # See https://github.com/teamcapybara/capybara/issues/2770
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: Selenium::WebDriver::Options.chrome(args:, browser_version: "127.0.6533.119"),
    http_client:,
  )
end

Capybara.server_port = 9887 + ENV["TEST_ENV_NUMBER"].to_i
Capybara.javascript_driver = :chrome_headless
Capybara.automatic_label_click = true
Capybara.default_max_wait_time = 10

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
