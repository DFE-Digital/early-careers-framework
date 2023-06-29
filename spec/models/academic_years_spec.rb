# frozen_string_literal: true

require "rails_helper"

RSpec.describe AcademicYear, type: :model do
  before do
    AcademicYear.delete_all
  end

  describe "#create!" do
    describe "when @id is not in the correct numerical format" do
      it "will not create an academic year" do
        expect { AcademicYear.create! id: "24/25" }.to raise_error ActiveRecord::RecordInvalid,
                                                                   "Validation failed: Id must be in the format dddd/dd"
      end
    end

    describe "when @id format is totally wrong" do
      it "will not create an academic year" do
        expect { AcademicYear.create! id: "AJX0006-23423-23523-LP" }.to raise_error ActiveRecord::RecordInvalid,
                                                                                    "Validation failed: Id must be in the format dddd/dd"
      end
    end

    describe "when @id spans more than two consecutive years" do
      it "will not create an academic year" do
        expect { AcademicYear.create! id: "5055/57" }.to raise_error ActiveRecord::RecordInvalid,
                                                                     "Validation failed: Id <5055/57> must represent two consecutive years not 3 years"
      end
    end

    describe "when @id spans two consecutive centuries" do
      it "will not create an academic year" do
        expect { AcademicYear.create! id: "5099/00" }.to_not raise_error
      end
    end

    describe "when academic year already exists in the database" do
      let(:label) { "4444/45" }
      let!(:existing_academic_year) { AcademicYear.create! id: label }

      it "will not create an academic year that already exists" do
        expect { AcademicYear.create! id: label }.to raise_error ActiveRecord::RecordInvalid,
                                                                 "Validation failed: Id has already been taken, Start year has already been taken, End year has already been taken"
      end
    end

    describe "when @start_date does not have the same year as the @id" do
      it "will not create an academic year" do
        expect { AcademicYear.create! id: "2222/23", start_date: Date.new(2223, 9, 1) }.to raise_error ActiveRecord::RecordInvalid,
                                                                                                       "Validation failed: Start date <2223-09-01 00:00:00 UTC> must have the year <2222>"
      end
    end

    describe "when @start_date was not provided" do
      subject(:created_academic_year) { AcademicYear.create! id: "2220/21" }

      it "will create an academic year" do
        expect { subject }.to_not raise_error
      end

      it "@start_date will default to 1st September" do
        is_expected.to have_attributes(start_date: Date.new(2220, 9, 1))
      end
    end

    describe "when :previous academic year already exists" do
      let!(:previous_academic_year) { AcademicYear.create! id: "2219/20" }
      subject(:created_academic_year) { AcademicYear.create! id: "2220/21" }

      it "will create an academic year" do
        expect { subject }.to_not raise_error
      end

      it "@previous_id will be set to the existing academic year" do
        is_expected.to have_attributes(previous_id: "2219/20")
      end
    end
  end

  describe "@end_date" do
    let!(:current_academic_year) { AcademicYear.create! id: "8887/88", start_date: Date.new(8887, 9, 1) }

    describe "when a next academic year has been configured" do
      let!(:next_academic_year) { AcademicYear.create! id: "8888/89", start_date: Date.new(8888, 8, 31) }

      it "returns 1 day before the start date of the next academic year" do
        expect(current_academic_year.next).to eq next_academic_year
        expect(current_academic_year.end_date).to eq next_academic_year.start_date - 1.day
      end
    end

    describe "when there is no next academic year" do
      it "returns nil" do
        expect(current_academic_year.end_date).to eq nil
      end
    end
  end

  describe "#label" do
    let(:academic_year) { AcademicYear.create! id: "6062/63" }

    it "displays the label that should be used to identify the academic year in the format dddd/dd" do
      expect(academic_year.label).to eq "6062/63"
    end
  end

  describe "#description" do
    let(:academic_year) { AcademicYear.create! id: "1034/35" }

    it "displays a description of the time period covered by the academic year in the format ' to '" do
      expect(academic_year.description).to eq "1034 to 1035"
    end
  end

  describe "#start_year" do
    let(:academic_year) { AcademicYear.create! id: "3024/25" }

    it "returns the start year as a integer" do
      expect(academic_year.start_year).to eq 3024
    end
  end

  describe "#display_name" do
    let(:academic_year) { AcademicYear.create! id: "7083/84" }

    it "returns the display name as a string representing the start year" do
      expect(academic_year.display_name).to eq "7083"
    end
  end

  describe "#previous" do
    let(:current_academic_year) { AcademicYear.create! id: "3031/32" }

    describe "when a previous academic year has been configured" do
      let!(:previous_academic_year) { AcademicYear.create! id: "3030/31" }

      it "returns the previous academic year" do
        expect(current_academic_year.previous).to eq previous_academic_year
      end
    end

    describe "when a previous academic year has not been configured" do
      let!(:previous_academic_year) { nil }

      it "returns nil" do
        expect(current_academic_year.previous).to eq nil
      end
    end
  end

  describe "#next" do
    let!(:current_academic_year) { AcademicYear.create! id: "3030/31" }

    describe "when a next academic year has been configured" do
      let!(:next_academic_year) { AcademicYear.create! id: "3031/32" }

      it "returns the next academic year" do
        expect(current_academic_year.next).to eq next_academic_year
      end

      it "returns the day before the next academic years start_date" do
        expect(current_academic_year.end_date).to eq next_academic_year.start_date - 1.day
      end
    end

    describe "when a next academic year has not been configured" do
      it "returns nil" do
        expect(current_academic_year.next).to eq nil
      end

      it "returns no end_date" do
        expect(current_academic_year.end_date).to eq nil
      end
    end
  end

  describe "#cohort" do
    let(:current_academic_year) { AcademicYear.create! id: "3030/31" }

    describe "when a cohort exists that matches the start year" do
      let!(:current_cohort) { Cohort.create! start_year: 3030 }

      it "returns the the cohort with the correct start_year" do
        expect(current_academic_year.cohort).to eq current_cohort
      end
    end

    describe "when a cohort does not exist that matches the start year" do
      let!(:current_cohort) { FactoryBot.create :seed_cohort, start_year: 3031 }

      it "returns nil" do
        expect(current_academic_year.cohort).to eq nil
      end
    end
  end

  describe "scopes" do
    let!(:first_academic_year) { AcademicYear.create! id: "7041/42", start_date: Date.new(7041, 9, 1), ecf_early_rollout_year: true }
    let!(:second_academic_year) { AcademicYear.create! id: "7042/43", start_date: Date.new(7042, 9, 1) }
    let!(:third_academic_year) { AcademicYear.create! id: "7043/44", start_date: Date.new(7043, 9, 1) }

    context "#all" do
      subject(:results) { AcademicYear.all }

      it { is_expected.to include first_academic_year, second_academic_year, third_academic_year }
    end

    context "#starts_before_date" do
      subject(:results) { AcademicYear.starts_before_date(Date.new(7043, 8, 1)) }

      it { is_expected.to include first_academic_year, second_academic_year }
      it { is_expected.to_not include third_academic_year }
    end

    context "#starts_after_date" do
      subject(:results) { AcademicYear.starts_after_date(Date.new(7041, 10, 10)) }

      it { is_expected.to_not include first_academic_year }
      it { is_expected.to include second_academic_year, third_academic_year }
    end

    context "#containing_date" do
      subject(:results) { AcademicYear.containing_date(Date.new(7042, 10, 10)) }

      it { is_expected.to include second_academic_year }
      it { is_expected.to_not include first_academic_year, third_academic_year }
    end

    context "#ecf_early_rollout_years" do
      subject(:results) { AcademicYear.ecf_early_rollout_years }

      it { is_expected.to include first_academic_year }
      it { is_expected.to_not include second_academic_year, third_academic_year }
    end

    context "#ecf_national_rollout_years" do
      subject(:results) { AcademicYear.ecf_national_rollout_years }

      it { is_expected.to include second_academic_year, third_academic_year }
      it { is_expected.to_not include first_academic_year }
    end

    context "#first_ecf_national_rollout_year" do
      subject(:results) { AcademicYear.first_ecf_national_rollout_year }

      it { is_expected.to eq second_academic_year }
    end
  end

  describe "AcademicYear.now" do
    describe "when the correct academic year exists" do
      let!(:current_academic_year) { AcademicYear.create! id: "4044/45" }

      it "returns the academic year which contains the date provided by Time.zone.today" do
        travel_to(Date.new(4044, 10, 10)) do
          expect(AcademicYear.now).to eq current_academic_year
        end
      end
    end

    describe "when the current academic year does not exist" do
      it "returns nil" do
        travel_to(200.years.from_now) do
          expect(AcademicYear.now).to eq nil
        end
      end
    end
  end
end
