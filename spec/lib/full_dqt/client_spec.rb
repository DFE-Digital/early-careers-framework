# frozen_string_literal: true

RSpec.describe FullDQT::Client do
  subject { described_class.new }

  let(:trn) { "1001000" }
  let(:incorrect_trn) { "1001009" }
  let(:birthdate) { Date.new(1987, 12, 13) }
  let(:nino) { "AB123456D" }

  let(:response_hash) do
    {
      "trn": trn,
      "ni_number": "AB123456D",
      "name": "Mostly Populated",
      "dob": "1987-12-13",
      "active_alert": false,
      "state": 0,
      "state_name": "Active",
      "qualified_teacher_status": {
        "name": "Qualified teacher (trained)",
        "qts_date": "2021-07-05T00:00:00Z",
        "state": 0,
        "state_name": "Active",
      },
      "induction": {
        "start_date": "2021-07-01T00:00:00Z",
        "completion_date": "2021-07-05T00:00:00Z",
        "status": "Pass",
        "state": 0,
        "state_name": "Active",
      },
      "initial_teacher_training": {
        "programme_start_date": "2021-06-27T00:00:00Z",
        "programme_end_date": "2021-07-04T00:00:00Z",
        "programme_type": "Overseas Trained Teacher Programme",
        "result": "Pass",
        "subject1": "applied biology",
        "subject2": "applied chemistry",
        "subject3": "applied computing",
        "qualification": "BA (Hons)",
        "state": 0,
        "state_name": "Active",
      },
      "qualifications": [
        {
          "name": "Higher Education",
          "date_awarded": nil,
        },
        {
          "name": "NPQH",
          "date_awarded": "2021-07-05T00:00:00Z",
        },
        {
          "name": "Mandatory Qualification",
          "date_awarded": nil,
        },
        {
          "name": "HLTA",
          "date_awarded": nil,
        },
        {
          "name": "NPQML",
          "date_awarded": "2021-07-05T00:00:00Z",
        },
        {
          "name": "NPQSL",
          "date_awarded": "2021-07-04T00:00:00Z",
        },
        {
          "name": "NPQEL",
          "date_awarded": "2021-07-04T00:00:00Z",
        },
      ],
    }
  end

  let(:stub_api_request) do
    stub_request(:get, "https://dtqapi.example.com/dqt-crm/v1/teachers/#{trn}?birthdate=#{birthdate}")
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
    stub_request(:get, "https://dtqapi.example.com/dqt-crm/v1/teachers/#{trn}?birthdate=#{birthdate}")
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

  let(:stub_api_different_record_request) do
    stub_request(:get, "https://dtqapi.example.com/dqt-crm/v1/teachers/#{incorrect_trn}?birthdate=#{birthdate}&nino=#{nino}")
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

  describe "#get_record" do
    it "returns teacher record" do
      stub_api_request

      record = subject.get_record(trn: trn, birthdate: birthdate)

      expect(record["trn"]).to eql(trn)
    end

    it "maps dates to native date objects" do
      stub_api_request

      record = subject.get_record(trn: trn, birthdate: birthdate)

      expect(record["dob"]).to be_an_instance_of(Date)
      expect(record["qualified_teacher_status"]["qts_date"]).to be_an_instance_of(ActiveSupport::TimeWithZone)
      expect(record["induction"]["start_date"]).to be_an_instance_of(ActiveSupport::TimeWithZone)
      expect(record["induction"]["completion_date"]).to be_an_instance_of(ActiveSupport::TimeWithZone)
      expect(record["initial_teacher_training"]["programme_start_date"]).to be_an_instance_of(ActiveSupport::TimeWithZone)
      expect(record["initial_teacher_training"]["programme_end_date"]).to be_an_instance_of(ActiveSupport::TimeWithZone)
      expect(record["qualifications"][0]["date_awarded"]).to be_nil
      expect(record["qualifications"][1]["date_awarded"]).to be_an_instance_of(ActiveSupport::TimeWithZone)
    end

    context "when record does not exist" do
      it "returns nil" do
        stub_api_404_request

        record = subject.get_record(trn: trn, birthdate: birthdate)

        expect(record).to be_nil
      end
    end

    context "with incorrect trn but correct nino" do
      it "returns correct record" do
        stub_api_different_record_request

        record = subject.get_record(trn: incorrect_trn, birthdate: birthdate, nino: nino)

        expect(record["trn"]).to eql(trn)
      end
    end
  end
end
