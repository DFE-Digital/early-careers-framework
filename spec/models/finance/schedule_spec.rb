# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule, type: :model do
  it { is_expected.to have_many(:milestones) }
  it { is_expected.to have_many(:participant_profiles) }
end

RSpec.describe Finance::Schedule::ECF, type: :model do
  before do
    load Rails.root.join("db/seeds/schedules.rb").to_s
  end

  subject { described_class.default }

  describe "default" do
    it "returns ECF September standard 2021 schedule" do
      expect(subject.name).to eql "ECF September standard 2021"
      expect(subject.cohort.start_year).to eql 2021
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

RSpec.describe Finance::Schedule::NPQLeadership, type: :model do
  before do
    load Rails.root.join("db/seeds/schedules.rb").to_s
  end

  it "seeds from csv" do
    schedule = described_class.find_by(schedule_identifier: "npq-leadership-spring")
    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(4)
  end

  describe "default" do
    it "returns NPQ Leadership November 2021 schedule" do
      expect(described_class.default.name).to eql "NPQ Leadership November 2021"
    end
  end
end

RSpec.describe Finance::Schedule::NPQSpecialist, type: :model do
  before do
    load Rails.root.join("db/seeds/schedules.rb").to_s
  end

  it "seeds from csv" do
    schedule = described_class.find_by(schedule_identifier: "npq-specialist-spring")
    expect(schedule).to be_present
    expect(schedule.milestones.count).to eql(3)
  end

  describe "default" do
    it "returns NPQ Specialist November 2021 schedule" do
      expect(described_class.default.name).to eql "NPQ Specialist November 2021"
    end
  end
end

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
    it "returns NPQ ASO November schedule" do
      expect(described_class.default.name).to eql "NPQ ASO November"
    end
  end
end
