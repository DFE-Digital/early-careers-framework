# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule::NPQSupport, type: :model do
  before do
    load Rails.root.join("db/seeds/schedules.rb").to_s
  end

  it "seeds from csv" do
    schedule = described_class.find_by(schedule_identifier: "npq-aso-march")
    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(4)
  end

  describe "default" do
    it "returns NPQ ASO December schedule" do
      expected_schedule = described_class.find_by(cohort: Cohort.current, schedule_identifier: "npq-aso-december")
      expect(described_class.default).to eql(expected_schedule)
    end
  end
end
