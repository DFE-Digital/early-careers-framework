# frozen_string_literal: true

require "rails_helper"

RSpec.describe DQTRecordPresenter, type: :model do
  let(:v1_dqt_record) do
    {
      "name" => "John Smith",
      "trn" => "1234567",
      "state_name" => "Active",
      "dob" => "01/01/2000",
      "ni_number" => "AB123456C",
      "active_alert" => true,
      "qualified_teacher_status" => {
        "qts_date" => "01/01/2020",
      },
      "induction" => {
        "start_date" => "01/01/2018",
        "completion_date" => "01/01/2019",
        "status" => "Completed",
      },
    }
  end

  let(:v3_dqt_record) do
    {
      "firstName" => "John",
      "middleName" => "Doe",
      "lastName" => "Smith",
      "trn" => "1234567",
      "dateOfBirth" => "01/01/2000",
      "nationalInsuranceNumber" => "AB123456C",
      "alerts" => [],
      "qts" => { "awarded" => "01/01/2020" },
      "induction" => {
        "startDate" => "01/01/2000",
        "endDate" => "01/01/2001",
        "status" => "InProgress",
        "periods" => [
          { "startDate" => "01/01/2003", "endDate" => "10/11/2003" },
          { "startDate" => "01/01/2000", "endDate" => "01/01/2001" },
          { "startDate" => nil, "endDate" => nil },
        ],
      },
    }
  end

  subject(:presenter) { described_class.new(v1_dqt_record) }

  describe "#name" do
    it "returns the name" do
      expect(presenter.name).to eq "John Smith"
    end
  end

  describe "#dob" do
    it "returns the date of birth" do
      expect(presenter.dob).to eq "01/01/2000"
    end
  end

  describe "#ni_number" do
    it "returns the national insurance number" do
      expect(presenter.ni_number).to eq "AB123456C"
    end
  end

  describe "#active?" do
    it "returns true when the state is Active" do
      expect(presenter.active?).to be true
    end
  end

  describe "#active_alert?" do
    it "returns false if the field is not present" do
      v1_dqt_record.delete("active_alert")
      expect(presenter.active_alert?).to be false
    end

    it "returns true when the active_alert field is present" do
      expect(presenter.active_alert?).to be true
    end
  end

  describe "#qts_date" do
    it "returns the QTS awarded date" do
      expect(presenter.qts_date).to eq "01/01/2020"
    end
  end

  describe "#induction_start_date" do
    context "when there are induction periods" do
      before do
        expect_any_instance_of(DQT::V3::Client).to receive(:get_record).with(trn: "1234567").and_return(v3_dqt_record)
      end

      it "returns the start date of the earliest induction period" do
        expect(presenter.induction_start_date).to eq "01/01/2000"
      end
    end

    context "when there are no induction periods" do
      before do
        v3_dqt_record["induction"]["periods"] = []
        expect_any_instance_of(DQT::V3::Client).to receive(:get_record).with(trn: "1234567").and_return(v3_dqt_record)
      end

      it "returns nil" do
        expect(presenter.induction_start_date).to be_nil
      end
    end
  end

  describe "#induction_completion_date" do
    context "when induction has been completed" do
      before do
        expect_any_instance_of(DQT::V3::Client).to receive(:get_record).with(trn: "1234567").and_return(v3_dqt_record)
      end

      it "returns the last end date of the latest induction period" do
        expect(presenter.induction_completion_date).to eq "10/11/2003"
      end
    end

    context "when induction is not completed" do
      it "returns nil" do
        v1_dqt_record["induction"]["status"] = "InProgress"
        expect(presenter.induction_completion_date).to be_nil
      end
    end

    context "when there are no induction periods" do
      before do
        v3_dqt_record["induction"]["periods"] = []
        expect_any_instance_of(DQT::V3::Client).to receive(:get_record).with(trn: "1234567").and_return(v3_dqt_record)
      end

      it "returns nil" do
        expect(presenter.induction_completion_date).to be_nil
      end
    end
  end

  describe "#exempt?" do
    it "returns false when the induction status is not Exempt" do
      expect(presenter.exempt?).to be false
    end

    it "returns true when the induction status is Exempt" do
      v1_dqt_record["induction"]["status"] = "Exempt"
      expect(presenter.exempt?).to be true
    end
  end
end
