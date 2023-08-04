# frozen_string_literal: true

RSpec.describe FullDQT::V3::Client do
  subject { described_class.new }

  let(:trn) { "1001000" }

  let(:response_hash) do
    {
      "trn": trn,
      "firstName": "Norman",
      "middleName": "Stanley",
      "lastName": "Fletcher",
      "nationalInsuranceNumber": "AB123456D",
      "dateOfBirth": "1987-12-13",
      "email": "norman@example.com",
      "qts": {
        "awarded": "2021-07-05",
      },
      "induction": {
        "startDate": "2021-07-01",
        "endDate": "2022-07-05",
        "status": "Pass",
      },
    }
  end

  let(:stub_api_request) do
    stub_request(:get, "https://dtqapi.example.com/dqt-crm/v3/teachers/#{trn}?include=induction")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer some-apikey-guid",
          "Host" => "dtqapi.example.com",
          "User-Agent" => "Ruby",
        },
      )
      .to_return(status: 200, body: response_hash.to_json, headers: {})
  end

  let(:stub_api_404_request) do
    stub_request(:get, "https://dtqapi.example.com/dqt-crm/v3/teachers/#{trn}?include=induction")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer some-apikey-guid",
          "Host" => "dtqapi.example.com",
          "User-Agent" => "Ruby",
        },
      )
      .to_return(status: 404, body: nil, headers: {})
  end

  describe "#get_record" do
    it "returns teacher record" do
      stub_api_request

      record = subject.get_record(trn:)

      expect(record["trn"]).to eql(trn)
    end

    it "maps dates to native date objects" do
      stub_api_request

      record = subject.get_record(trn:)

      expect(record["dateOfBirth"]).to be_an_instance_of(Date)
      expect(record["qts"]["awarded"]).to be_an_instance_of(Date)
      expect(record["induction"]["startDate"]).to be_an_instance_of(Date)
      expect(record["induction"]["endDate"]).to be_an_instance_of(Date)
    end

    context "when record does not exist" do
      it "returns nil" do
        stub_api_404_request

        record = subject.get_record(trn:)

        expect(record).to be_nil
      end
    end
  end
end
