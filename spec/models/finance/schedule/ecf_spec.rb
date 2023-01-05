# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule::ECF, type: :model do
  before do
    load Rails.root.join("db/legacy_seeds/schedules.rb").to_s
  end

  subject(:ecf_schedule) { described_class }

  describe "default" do
    context "when registration cohort is 2021", travel_to: Date.new(2021, 11, 1) do
      it "returns ECF September standard 2021 schedule" do
        expect(ecf_schedule.default.name).to eql "ECF Standard September"
        expect(ecf_schedule.default.cohort.start_year).to eql(2021)
      end
    end
  end

  describe "default_for" do
    context "when registration cohort is 2021" do
      let(:cohort) { Cohort.find_by(start_year: 2021) }

      it "returns ECF September standard 2021 schedule" do
        expect(ecf_schedule.default_for(cohort:).name).to eql "ECF Standard September"
        expect(ecf_schedule.default_for(cohort:).cohort.start_year).to eql(2021)
      end
    end
  end

  context "for 2021 cohort" do
    let(:cohort) { Cohort.find_by(start_year: 2021) }

    it "seeds ecf schedules and milestones" do
      schedule = described_class.find_by(cohort:, schedule_identifier: "ecf-standard-april")

      expect(schedule).to be_present
      expect(schedule.milestones.count).to eql(6)

      schedule = described_class.find_by(cohort:, schedule_identifier: "ecf-reduced-april")

      expect(schedule).to be_present
      expect(schedule.milestones.count).to eql(6)

      schedule = described_class.find_by(cohort:, schedule_identifier: "ecf-extended-april")

      expect(schedule).to be_present
      expect(schedule.milestones.count).to eql(6)

      schedule = described_class.find_by(cohort:, schedule_identifier: "ecf-replacement-april")

      expect(schedule).to be_present
      expect(schedule.milestones.count).to eql(6)
    end
  end
end
