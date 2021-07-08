# frozen_string_literal: true

require "rails_helper"

RSpec.describe CpdLeadProvider, type: :model do
  it "can be created" do
    expect {
      described_class.create(name: "Test Lead Provider")
    }.to change { described_class.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to have_one(:lead_provider) }
    it { is_expected.to have_one(:npq_lead_provider) }
  end
end
