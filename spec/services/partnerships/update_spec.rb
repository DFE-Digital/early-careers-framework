# frozen_string_literal: true

require "rails_helper"

RSpec.describe Partnerships::Update do
  let(:school) { create :school, :open, administrative_district_code: "E123", school_type_code: 1 }
  let(:cohort) { create :cohort }
  let(:lead_provider) { create :lead_provider }
  let(:delivery_partner) { create :delivery_partner }
  let!(:provider_relationship) { create(:provider_relationship, lead_provider:, delivery_partner:, cohort:) }
  let!(:partnership) { create(:partnership, school:, cohort:, delivery_partner:, lead_provider:) }

  let(:delivery_partner2) { create(:delivery_partner, name: "Second Delivery Partner") }
  let!(:provider_relationship2) { create(:provider_relationship, lead_provider:, delivery_partner: delivery_partner2, cohort:) }

  let(:params) do
    {
      partnership:,
      delivery_partner_id: delivery_partner2.id,
    }
  end

  subject(:service) { described_class.new(**params) }

  describe "#call" do
    context "missing params" do
      let(:params) do
        {
          partnership: nil,
          delivery_partner_id: nil,
        }
      end

      it "returns errors" do
        expect(service).to be_invalid

        expect(service.errors.messages_for(:partnership)).to include("The attribute '#/partnership' must be included as part of partnership confirmations.")
        expect(service.errors.messages_for(:delivery_partner_id)).to include("The attribute '#/delivery_partner_id' must be included as part of partnership confirmations.")
      end
    end

    context "invalid params" do
      let(:params) do
        {
          partnership:,
          delivery_partner_id: "invalid_value",
        }
      end

      it "returns errors" do
        expect(service).to be_invalid

        expect(service.errors.messages_for(:delivery_partner_id)).to include("The '#/delivery_partner_id' you have entered is invalid. Check delivery partner details and try again.")
      end
    end

    context "valid params" do
      it "creates a new partnership" do
        expect(Partnership.count).to eql(1)
        part = Partnership.first
        expect(part.cohort_id).to eq(cohort.id)
        expect(part.lead_provider_id).to eq(lead_provider.id)
        expect(part.school_id).to eq(school.id)
        expect(part.delivery_partner_id).to eq(delivery_partner.id)

        expect(service).to be_valid
        service.call

        expect(Partnership.count).to eql(1)
        part.reload
        expect(part.cohort_id).to eq(cohort.id)
        expect(part.lead_provider_id).to eq(lead_provider.id)
        expect(part.school_id).to eq(school.id)
        expect(part.delivery_partner_id).to eq(delivery_partner2.id)
      end
    end

    context "delivery partner cohort" do
      context "In cohort" do
        let!(:provider_relationship2) { create(:provider_relationship, lead_provider:, delivery_partner: delivery_partner2, cohort:) }

        it "does not show error" do
          expect(service).to be_valid

          expect(service.errors.messages_for(:delivery_partner_id)).to be_blank
        end
      end

      context "not in cohort" do
        let(:different_cohort) { create(:cohort) }
        let!(:provider_relationship2) { create(:provider_relationship, lead_provider:, delivery_partner: delivery_partner2, cohort: different_cohort) }

        it "returns errors" do
          expect(service).to be_invalid

          expect(service.errors.messages_for(:delivery_partner_id)).to include("The entered delivery partner is not recognised to be working in partnership with you for the given cohort. Contact the DfE for more information.")
        end
      end
    end

    context "partnership challenged" do
      let!(:partnership) { create(:partnership, :challenged, school:, cohort:, delivery_partner:, lead_provider:) }

      it "returns errors" do
        expect(service).to be_invalid

        expect(service.errors.messages_for(:delivery_partner_id)).to include("Your update cannot be made as this partnership has been challenged by the school. If this partnership has been challenged in error, submit a new partnership confirmation using the endpoint POST /api/v3/partnerships/ecf.")
      end
    end

    context "update with same delivery partner" do
      let(:params) do
        {
          partnership:,
          delivery_partner_id: delivery_partner.id,
        }
      end

      it "should leave partnership unchained" do
        expect(::Partnerships::Report).to_not receive(:call)

        expect(Partnership.count).to eql(1)
        expect(service).to be_valid
        returned_partnership = service.call

        expect(Partnership.count).to eql(1)
        expect(returned_partnership).to eql(partnership)
        expect(returned_partnership.delivery_partner).to eql(delivery_partner)
      end
    end

    context "existing 'relationship=true' partnership with delivery_partner2" do
      let!(:partnership2) { create(:partnership, school:, cohort:, delivery_partner: delivery_partner2, lead_provider:, relationship: true) }

      let(:params) do
        {
          partnership:,
          delivery_partner_id: delivery_partner2.id,
        }
      end

      it "returns errors" do
        expect(Partnership.count).to eql(2)
        expect(service).to be_invalid

        expect(service.errors.messages_for(:delivery_partner_id)).to include("We are unable to process this request. You are already confirmed to be in partnership with the entered delivery partner. Contact the DfE for support.")
      end
    end
  end
end
