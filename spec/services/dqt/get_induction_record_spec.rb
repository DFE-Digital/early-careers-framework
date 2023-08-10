# frozen_string_literal: true

RSpec.describe DQT::GetInductionRecord do
  describe "#call" do
    let(:trn) { "1000864" }
    let(:valid_record) do
      {
        "trn" => "1000864",
        "firstName" => "Peter",
        "middleName"=>"",
        "lastName" => "Bonetti",
        "dateOfBirth"=> Date.new(1987, 3, 1),
        "nationalInsuranceNumber" => "QQ123456Q",
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

    it "returns the induction section of the participants DQT record" do
      expect_any_instance_of(FullDQT::V3::Client).to receive(:get_record).with(trn:).once.and_return(valid_record)

      result = service.call(trn:)

      expect(result).to eq valid_record["induction"]
    end

    context "when the record is not found" do
      it "returns nil" do
        expect_any_instance_of(FullDQT::V3::Client).to receive(:get_record).with(trn:).once.and_return(nil)

        result = service.call(trn:)

        expect(result).to be_nil
      end
    end
  end
end
