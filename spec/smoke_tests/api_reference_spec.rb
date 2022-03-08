# frozen_string_literal: true

require "capybara/rspec"
require "yaml"

RSpec.describe "API Reference pages", smoke_test: true do
  let(:smoke_test_domain) { fetch_smoke_test_domain }

  before do
    skip "No domain for smoke tests found" unless smoke_test_domain
    WebMock.allow_net_connect!
  end

  it "ensures tech docs pages exist" do
    page_should_exist("/api-reference")
    page_should_exist("/api-reference/ecf-usage")
    page_should_exist("/api-reference/npq-usage")
    page_should_exist("/api-reference/reference-v1")
    page_should_exist("/api-reference/release-notes")
    page_should_exist("/api-reference/help")
  end

private

  def fetch_smoke_test_domain
    paas_environment = ENV.fetch("ENVIRONMENT")
    YAML.load_file("#{__dir__}/../../terraform/workspace-variables/#{paas_environment}_app_env.yml")["DOMAIN"]
  rescue Errno::ENOENT
    "ecf-#{paas_environment}.london.cloudapps.digital"
  rescue KeyError
    nil
  end

  def page_should_exist(path)
    uri = URI("https://#{smoke_test_domain}#{path}")
    req = Net::HTTP::Get.new(uri)
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    res = http.request(req)
    expect(res).to be_a Net::HTTPSuccess
  end
end
