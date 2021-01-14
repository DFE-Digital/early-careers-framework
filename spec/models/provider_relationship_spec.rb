# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProviderRelationship, type: :model do
  it "can be created" do
    expect {
      ProviderRelationship.create(
        lead_provider: create(:lead_provider),
        delivery_partner: create(:delivery_partner),
        cohort: create(:cohort),
      )
    }.to change { ProviderRelationship.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to belong_to(:delivery_partner) }
    it { is_expected.to belong_to(:cohort) }
  end
end
