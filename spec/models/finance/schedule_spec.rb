# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::Schedule, type: :model do
  it { is_expected.to have_many(:milestones) }
  it { is_expected.to have_many(:participant_profiles) }
end

RSpec.describe Finance::Schedule::ECF, type: :model do
  before do
    seed_path = %w[db seeds]
    load Rails.root.join(*seed_path, "schedules.rb").to_s
  end

  describe "default" do
    it "returns ECF September standard 2021 schedule" do
      expect(described_class.default.name).to eq "ECF September standard 2021"
    end
  end
end

RSpec.describe Finance::Schedule::NPQLeadership, type: :model do
  before do
    seed_path = %w[db seeds]
    load Rails.root.join(*seed_path, "schedules.rb").to_s
  end

  describe "default" do
    it "returns ECF September standard 2021 schedule" do
      expect(described_class.default.name).to eq "NPQ Leadership November 2021"
    end
  end
end

RSpec.describe Finance::Schedule::NPQSpecialist, type: :model do
  before do
    seed_path = %w[db seeds]
    load Rails.root.join(*seed_path, "schedules.rb").to_s
  end

  describe "default" do
    it "returns ECF September standard 2021 schedule" do
      expect(described_class.default.name).to eq "NPQ Specialist November 2021"
    end
  end
end
