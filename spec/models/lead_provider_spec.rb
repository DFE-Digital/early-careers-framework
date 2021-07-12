# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProvider, type: :model do
  it "can be created" do
    expect {
      LeadProvider.create(name: "Test Lead Provider")
    }.to change { LeadProvider.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider).required(false) }

    it { is_expected.to have_many(:partnerships) }
    it { is_expected.to have_many(:schools).through(:partnerships) }
    it { is_expected.to have_many(:lead_provider_profiles) }
    it { is_expected.to have_many(:users).through(:lead_provider_profiles) }
    it { is_expected.to have_many(:provider_relationships) }
    it { is_expected.to have_many(:delivery_partners).through(:provider_relationships) }
    it { is_expected.to have_many(:partnership_csv_uploads) }
    it { is_expected.to have_many(:participation_records) }
    it { is_expected.to have_one(:call_off_contract) }
  end
end
