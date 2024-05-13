# frozen_string_literal: true

RSpec.describe DQT::GetTeacherRecord do
  describe "#call" do
    let(:trn) { "1000864" }
    let(:date_of_birth) { Date.new(1987, 3, 1) }
    let(:nino) { "QQ123456Q" }
    let(:valid_record) do
      {
        "trn" => "1000864",
        "firstName" => "Peter",
        "middleName"=>"",
        "lastName" => "Bonetti",
        "dateOfBirth"=> date_of_birth,
        "nationalInsuranceNumber" => nino,
        "email" => nil,
        "qts" => { "awarded" => 2.years.ago.to_date },
        "eyts" => nil,
        "induction" => { "startDate" => 18.months.ago.to_date,
                         "endDate" => nil,
                         "status" => "InProgress",
                         "periods"=>[{ "startDate" => 18.months.ago.to_date,
                                      "endDate" => nil,
                                      "terms" => nil,
                                      "appropriateBody" => { "name" => "The Most Fantasic AB Ltd" } }] },
      }
    end

    subject(:service) { described_class }

    it "returns the participants DQT record" do
      expect_any_instance_of(FullDQT::V3::Client).to receive(:get_record).with(trn:).once.and_return(valid_record)

      result = service.call(trn:)

      expect(result).to eq valid_record
    end

    context "when the record is not found" do
      it "returns nil" do
        expect_any_instance_of(FullDQT::V3::Client).to receive(:get_record).with(trn:).once.and_return(nil)

        result = service.call(trn:)

        expect(result).to be_nil
      end
    end

    context "when date_of_birth is provided" do
      it "returns the participants DQT record" do
        expect_any_instance_of(FullDQT::V3::Client).to receive(:get_record).with(trn:, date_of_birth:).once.and_return(valid_record)

        result = service.call(trn:, date_of_birth:)

        expect(result).to eq valid_record
      end
    end

    context "when nino is provided" do
      it "returns the participants DQT record" do
        expect_any_instance_of(FullDQT::V1::Client).to receive(:get_record)
          .with(trn: nil, birthdate: date_of_birth, nino:)
          .once.and_return(valid_record)

        result = service.call(trn: nil, date_of_birth:, nino:)

        expect(result).to eq valid_record
      end
    end
  end
end
