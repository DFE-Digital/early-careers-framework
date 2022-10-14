# frozen_string_literal: true

require "rails_helper"

module Api
  module V3
    module ECF
      RSpec.describe PartnershipSerializer do
        describe "serialization" do
          let(:lead_provider) { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
          let(:delivery_partner) { create(:delivery_partner, name: "First Delivery Partner") }
          let(:cohort) { create(:cohort) }
          let!(:provider_relationship) { create(:provider_relationship, cohort:, delivery_partner:, lead_provider:) }
          let(:school) { create(:school, urn: "123456", name: "My first High School") }
          let(:induction_coordinator) { create(:user, full_name: "Induction Coordinator", email: "ic@example.com") }
          let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [school], user: induction_coordinator) }
          let!(:partnership) { create(:partnership, :challenged, school:, cohort:, delivery_partner:, lead_provider:) }

          subject { described_class.new([partnership]) }

          it "returns the expected data" do
            result = subject.serializable_hash

            expect(result[:data]).to match_array([
              id: partnership.id,
              type: :'partnership-confirmation',
              attributes: {
                cohort: cohort.start_year,
                urn: school.urn,
                delivery_partner_id: partnership.delivery_partner_id,
                delivery_partner_name: partnership.delivery_partner.name,
                status: "challenged",
                challenged_reason: partnership.challenge_reason,
                induction_tutor_name: school.induction_tutor.full_name,
                induction_tutor_email: school.contact_email,
                updated_at: delivery_partner.updated_at.rfc3339,
                created_at: delivery_partner.created_at.rfc3339,
              },
            ])
          end
        end
      end
    end
  end
end
