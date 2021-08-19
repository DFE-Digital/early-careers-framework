# frozen_string_literal: true

require "capybara/rspec"
require "yaml"

CLOUDAPPS_DOMAIN = "london.cloudapps.digital"

RSpec.describe "Participant API availability", smoke_test: true do
  context "ECF participant declarations" do
    let(:smoke_test_domain) { fetch_smoke_test_domain }

    before do
      WebMock.allow_net_connect!
    end

    it "ensures participant declaration api allows declarations" do
      if smoke_test_domain
        participant = fetch_first_active_participant
        res = make_started_declaration(participant)
        expect(res).to be_a Net::HTTPSuccess
      else
        puts "No domain for smoke tests found, skipping..."
      end
    end
  end

private

  def fetch_smoke_test_domain
    paas_environment = ENV.fetch("ENVIRONMENT")
    YAML.load_file("#{__dir__}/../../terraform/workspace-variables/#{paas_environment}_app_env.yml")["DOMAIN"]
  rescue Errno::ENOENT
    "ecf-#{paas_environment}.#{CLOUDAPPS_DOMAIN}"
  rescue KeyError
    nil
  end

  def fetch_first_active_participant
    uri = URI("https://#{smoke_test_domain}/api/v1/participants")
    req = Net::HTTP::Get.new(uri, "Authorization" => "Bearer ambition-token")
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    res = http.request(req)

    JSON.parse(res.body)["data"].filter { |p| p["attributes"]["status"] != "withdrawn" }.first
  end

  def participant_declaration_body(participant)
    course_identifier = participant["attributes"]["participant_type"] == "ect" ? "ecf-induction" : "ecf-mentor"
    {
      "data": {
        "type": "participant-declaration",
        "attributes": {
          "participant_id": participant["id"],
          "declaration_type": "started",
          "declaration_date": Date.new(2021, 9, 2).rfc3339,
          "course_identifier": course_identifier,
        },
      },
    }.to_json
  end

  def make_started_declaration(participant)
    uri = URI("https://#{smoke_test_domain}/api/v1/participant-declarations")
    req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json", "Authorization" => "Bearer ambition-token", "X_WITH_SERVER_DATE" => Date.new(2021, 9, 3).rfc3339)
    req.body = participant_declaration_body(participant)
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.request(req)
  end
end
