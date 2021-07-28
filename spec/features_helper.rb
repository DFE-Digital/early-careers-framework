# frozen_string_literal: true

require "capybara"
require "capybara/rspec"
require "axe-rspec"
require "webdrivers/chromedriver"
require "percy/capybara"

Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1400")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome_headless

RSpec.configure do |config|
  config.include AxeAndPercyHelper, type: :feature

  # need this for percy and axe
  config.before(:each, type: :feature) do
    WebMock.disable_net_connect!(allow_localhost: true,
                                 allow: "chromedriver.storage.googleapis.com")
  end
end
