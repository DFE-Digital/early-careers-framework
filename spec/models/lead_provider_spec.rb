# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProvider, type: :model do
  it "can be created" do
    expect {
      LeadProvider.create(name: "Test Lead Provider")
    }.to change { LeadProvider.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to have_many(:partnerships) }
    it { is_expected.to have_many(:schools).through(:partnerships) }
    it { is_expected.to have_many(:lead_provider_profiles) }
    it { is_expected.to have_many(:provider_relationships) }
    it { is_expected.to have_many(:delivery_partners).through(:provider_relationships) }
  end
end
