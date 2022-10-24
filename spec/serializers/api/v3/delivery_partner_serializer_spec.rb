# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    RSpec.describe DeliveryPartnerSerializer do
      describe "serialization" do
        let(:lead_provider) { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
        let(:delivery_partner) { create(:delivery_partner) }
        let(:cohort) { create(:cohort) }
        let!(:provider_relationship) { create(:provider_relationship, cohort:, delivery_partner:, lead_provider:) }

        subject { described_class.new([delivery_partner], params: { lead_provider: }) }

        it "returns the expected data" do
          result = subject.serializable_hash

          expect(result[:data]).to match_array([
            id: delivery_partner.id,
            type: :'delivery-partner',
            attributes: {
              name: delivery_partner.name,
              updated_at: delivery_partner.updated_at.rfc3339,
              cohort: [cohort.display_name],
            },
          ])
        end
      end
    end
  end
end
