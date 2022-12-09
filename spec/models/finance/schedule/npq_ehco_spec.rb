# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule::NPQEhco, type: :model do
  before do
    load Rails.root.join("db/legacy_seeds/schedules.rb").to_s
  end

  it "seeds from csv" do
    schedule = described_class.find_by(schedule_identifier: "npq-ehco-march")
    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(4)
  end

  describe "default" do
    it "returns NPQ EHCO December schedule" do
      expected_schedule = described_class.find_by(cohort: Cohort.find_by!(start_year: 2022), schedule_identifier: "npq-ehco-december")
      expect(described_class.default).to eql(expected_schedule)
    end
  end
end
