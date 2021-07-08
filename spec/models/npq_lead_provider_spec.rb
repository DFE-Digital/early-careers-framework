# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQLeadProvider, type: :model do
  it "can be created" do
    expect {
      described_class.create(name: "Test Lead Provider")
    }.to change { described_class.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider).required(false) }
  end
end
