# frozen_string_literal: true

require "rails_helper"

RSpec.describe DQTRecordPresenter, type: :model do
  let(:dqt_record) do
    {
      "firstName" => "John",
      "middleName" => "Doe",
      "lastName" => "Smith",
      "trn" => "1234567",
      "dateOfBirth" => "01/01/2000",
      "nationalInsuranceNumber" => "AB123456C",
      "alerts" => [],
      "qts" => { "awarded" => "01/01/2000" },
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

  subject(:presenter) { described_class.new(dqt_record) }

  describe "#full_name" do
    it "returns the full name" do
      expect(presenter.full_name).to eq "John Doe Smith"
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

    context "when the DQT record is nil" do
      let(:dqt_record) { nil }
      it "returns false" do
        expect(presenter.active?).to be false
      end
    end
  end

  describe "#active_alert?" do
    it "returns false when there are no alerts" do
      expect(presenter.active_alert?).to be false
    end

    it "returns true when alerts are present" do
      dqt_record["alerts"] = %w[Alert]
      expect(presenter.active_alert?).to be true
    end
  end

  describe "#qts_date" do
    it "returns the QTS awarded date" do
      expect(presenter.qts_date).to eq "01/01/2000"
    end
  end

  describe "#induction_start_date" do
    it "returns the start date of the earliest induction period" do
      expect(presenter.induction_start_date).to eq "01/01/2000"
    end
  end

  describe "#induction_completion_date" do
    it "returns the last end date of the latest induction period" do
      expect(presenter.induction_completion_date).to eq "10/11/2003"
    end
  end

  describe "#exempt?" do
    it "returns false when the induction status is not Exempt" do
      expect(presenter.exempt?).to be false
    end

    it "returns true when the induction status is Exempt" do
      dqt_record["induction"]["status"] = "Exempt"
      expect(presenter.exempt?).to be true
    end
  end

  context "with a v1 DQT record" do
    let(:dqt_record) do
      {
        "name" => "John Smith",
        "trn" => "1234567",
        "state_name" => "Active",
        "dob" => "02/02/2002",
        "ni_number" => "AB123456C",
        "active_alert" => false,
        "qualified_teacher_status" => {
          "qts_date" => "01/01/2020",
        },
        "induction" => {
          "start_date" => "01/01/2018",
          "completion_date" => "01/01/2019",
        },
      }
    end

    it "returns the full name" do
      expect(presenter.full_name).to eq "John Smith"
    end

    it "returns the first name" do
      expect(presenter.first_name).to eq "John"
    end

    it "returns the last name" do
      expect(presenter.last_name).to eq "Smith"
    end

    it "returns the date of birth" do
      expect(presenter.dob).to eq "02/02/2002"
    end

    it "returns the national insurance number" do
      expect(presenter.ni_number).to eq "AB123456C"
    end

    it "returns true when the state is Active" do
      expect(presenter.active?).to be true
    end

    it "returns false when there are no alerts" do
      expect(presenter.active_alert?).to be false
    end

    it "returns the QTS awarded date" do
      expect(presenter.qts_date).to eq "01/01/2020"
    end

    it "returns the induction start date" do
      expect(presenter.induction_start_date).to eq "01/01/2018"
    end

    it "returns the induction completion date" do
      expect(presenter.induction_completion_date).to eq "01/01/2019"
    end
  end
end
