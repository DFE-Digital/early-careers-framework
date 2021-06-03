# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartnerForm, type: :model do
  describe "#save!" do
    context "when another delivery partner is working with the lead provider" do
      let(:lead_provider) { create(:lead_provider) }
      let(:other_delivery_partner) { create(:delivery_partner) }
      let(:cohort) { create(:cohort, :current) }
      before do
        ProviderRelationship.create!(lead_provider: lead_provider, delivery_partner: other_delivery_partner, cohort: cohort)
      end

      it "does not affect provider relationships for other delivery partners when creating" do
        form = DeliveryPartnerForm.new(
          name: "new delivery partner",
          lead_provider_ids: [lead_provider.id],
          provider_relationship_hashes: [{ "lead_provider_id" => lead_provider.id, "cohort_id" => cohort.id }.to_json],
        )
        form.save!

        expect(other_delivery_partner.provider_relationships.count).to eql 1
      end

      it "does not affect provider relationships for other delivery partners when updating" do
        delivery_partner = create(:delivery_partner)
        form = DeliveryPartnerForm.new(
          name: delivery_partner.name,
          lead_provider_ids: [lead_provider.id],
          provider_relationship_hashes: [{ "lead_provider_id" => lead_provider.id, "cohort_id" => cohort.id }.to_json],
        )
        form.save!(delivery_partner)

        expect(other_delivery_partner.provider_relationships.count).to eql 1
      end

      it "creates the delivery partner and provider relationship" do
        form = DeliveryPartnerForm.new(
          name: "new delivery partner",
          lead_provider_ids: [lead_provider.id],
          provider_relationship_hashes: [{ "lead_provider_id" => lead_provider.id, "cohort_id" => cohort.id }.to_json],
        )
        form.save!

        new_delivery_partner = DeliveryPartner.find_by(name: "new delivery partner")
        expect(new_delivery_partner).not_to be_nil
        expect(new_delivery_partner.provider_relationships.count).to eq 1
        expect(new_delivery_partner.provider_relationships.first.lead_provider).to eql lead_provider
      end

      it "updates the delivery partner with a new provider relationship" do
        delivery_partner = create(:delivery_partner)
        form = DeliveryPartnerForm.new(
          name: delivery_partner.name,
          lead_provider_ids: [lead_provider.id],
          provider_relationship_hashes: [{ "lead_provider_id" => lead_provider.id, "cohort_id" => cohort.id }.to_json],
        )
        form.save!(delivery_partner)

        expect(delivery_partner.reload.provider_relationships.count).to eq 1
        expect(delivery_partner.reload.provider_relationships.first.lead_provider).to eql lead_provider
      end
    end
  end
end
