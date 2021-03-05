# frozen_string_literal: true

require "rails_helper"
require "gias_api_client"
require "savon/mock/spec_helper"

RSpec.describe GiasApiClient do
  include Savon::SpecHelper

  let(:gias_api_client) { GiasApiClient.new }
  let(:gias_schema_response) { File.open("spec/fixtures/files/gias_schema_response.txt") }
  let(:example_gias_response) { File.open("spec/fixtures/files/example_gias_response.txt", "rb", &:read) }
  let(:schema_url) { /example-gias/ }
  let!(:schema_request) { stub_request(:get, schema_url).to_return(gias_schema_response) }

  before(:all) { savon.mock! }
  after(:all) { savon.unmock! }

  describe "#get_files" do
    before do
      savon.expects(:get_extract).with(message: { "tns:Id" => 1234 }).returns(
        code: 200,
        body: example_gias_response,
        headers: {
          "Keep-Alive" => "timeout=20",
          "Transfer-Encoding" => "chunked",
          "Content-Type" => 'Multipart/Related; boundary="----=_Part_2176_1368626461.1614687322870"; type="application/xop+xml"; start-info="text/xml"',
          "Set-Cookie" => "JSESSIONID=F2C9023D58CD27BB4C7634BA169CE574; Path=/edubase; Secure; HttpOnly",
          "Accept" => "text/xml, text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2",
          "SOAPAction" => '""',
          "X-Powered-By" => "ASP.NET",
          "Date" => "Tue, 02 Mar 2021 19:06:24 GMT",
        },
      )
    end

    it "returns a hash of files" do
      files = gias_api_client.get_files
      expect(files).to be_a_kind_of Hash
      expect(files.keys).to contain_exactly("ecf_tech.csv", "groupLinks.csv", "groups.csv", "links.csv")
      expect(files.values.first).to be_a_kind_of Tempfile
    end
  end
end
