# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule::ECF, type: :model do
  before do
    load Rails.root.join("db/seeds/schedules.rb").to_s
  end

  subject { described_class.default }

  describe "default" do
    it "returns ECF September standard 2021 schedule" do
      expect(subject.name).to eql "ECF Standard September"
      expect(subject.cohort.start_year).to eql(2021)
    end
  end

  it "seeds ecf schedules and milestones" do
    schedule = described_class.find_by(schedule_identifier: "ecf-standard-april")

    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(6)

    schedule = described_class.find_by(schedule_identifier: "ecf-reduced-april")

    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(6)

    schedule = described_class.find_by(schedule_identifier: "ecf-extended-april")

    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(6)

    schedule = described_class.find_by(schedule_identifier: "ecf-replacement-april")

    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(6)
  end
end
