# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartnerForm, type: :model do
  describe "#save!" do
    it "does not affect provider relationships for other delivery partners" do
      lead_provider = create(:lead_provider)
      other_delivery_partner = create(:delivery_partner)
      cohort = create(:cohort, :current)
      ProviderRelationship.create!(lead_provider: lead_provider, delivery_partner: other_delivery_partner, cohort: cohort)

      form = DeliveryPartnerForm.new(
        name: "new delivery partner",
        lead_provider_ids: [lead_provider.id],
        provider_relationship_hashes: [{ "lead_provider_id" => lead_provider.id, "cohort_id" => cohort.id }.to_json],
      )
      form.save!

      expect(other_delivery_partner.provider_relationships.count).to eql 1
    end
  end
end
