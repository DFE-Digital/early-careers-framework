# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule::NPQSpecialist, type: :model do
  before do
    load Rails.root.join("db/legacy_seeds/schedules.rb").to_s
  end

  it "seeds from csv" do
    schedule = described_class.find_by(schedule_identifier: "npq-specialist-spring")
    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(3)
  end

  describe "default" do
    it "returns NPQ Specialist Spring 2021 schedule" do
      expected_schedule = described_class.find_by(cohort: Cohort.current, schedule_identifier: "npq-specialist-spring")
      expect(described_class.default).to eql(expected_schedule)
    end
  end
end
