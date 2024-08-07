# frozen_string_literal: true

require "rails_helper"

RSpec.describe Partnerships::Create do
  let(:school) { create :school, :open, administrative_district_code: "E123", school_type_code: 1 }
  let(:cohort) { create :cohort }
  let(:lead_provider) { create :lead_provider }
  let(:delivery_partner) { create :delivery_partner }
  let!(:provider_relationship) { create(:provider_relationship, lead_provider:, delivery_partner:, cohort:) }

  let(:params) do
    {
      cohort: cohort.start_year,
      school_id: school.id,
      lead_provider_id: lead_provider.id,
      delivery_partner_id: delivery_partner.id,
    }
  end

  subject(:service) { described_class.new(**params) }

  describe "#call" do
    context "missing params" do
      let(:params) do
        {
          cohort: nil,
          school_id: nil,
          lead_provider_id: nil,
          delivery_partner_id: nil,
        }
      end

      it "returns errors" do
        expect(service).to be_invalid

        expect(service.errors.messages_for(:cohort)).to include("Enter a '#/cohort'.")
        expect(service.errors.messages_for(:school_id)).to include("Enter a '#/school_id'.")
        expect(service.errors.messages_for(:lead_provider_id)).to include("Enter a '#/lead_provider_id'.")
        expect(service.errors.messages_for(:delivery_partner_id)).to include("Enter a '#/delivery_partner_id'.")
      end
    end

    context "invalid params" do
      let(:params) do
        {
          cohort: "invalid_value",
          school_id: "invalid_value",
          lead_provider_id:  "invalid_value",
          delivery_partner_id:  "invalid_value",
        }
      end

      it "returns errors" do
        expect(service).to be_invalid

        expect(service.errors.messages_for(:cohort)).to include("The '#/cohort' you have entered is invalid. Check cohort details and try again.")
        expect(service.errors.messages_for(:school_id)).to include("The '#/school_id' you have entered is invalid. Check school details and try again. Contact the DfE for support if you are unable to find the '#/school_id'.")
        expect(service.errors.messages_for(:lead_provider_id)).to include("Enter a valid '#/lead_provider_id'.")
        expect(service.errors.messages_for(:delivery_partner_id)).to include("The '#/delivery_partner_id' you have entered is invalid. Check delivery partner details and try again.")
      end
    end

    context "valid params" do
      it "creates a new partnership" do
        expect(Partnership.count).to eql(0)
        expect(service).to be_valid
        service.call

        expect(Partnership.count).to eql(1)
        partnership = Partnership.first
        expect(partnership.cohort_id).to eq(cohort.id)
        expect(partnership.delivery_partner_id).to eq(delivery_partner.id)
        expect(partnership.lead_provider_id).to eq(lead_provider.id)
        expect(partnership.school_id).to eq(school.id)
      end
    end

    context "delivery partner cohort" do
      context "In cohort" do
        let!(:provider_relationship) { create(:provider_relationship, lead_provider:, delivery_partner:, cohort:) }

        it "does not show error" do
          expect(service).to be_valid

          expect(service.errors.messages_for(:delivery_partner_id)).to be_blank
        end
      end

      context "not in cohort" do
        let(:different_cohort) { create(:cohort) }
        let!(:provider_relationship) { create(:provider_relationship, lead_provider:, delivery_partner:, cohort: different_cohort) }

        it "returns errors" do
          expect(service).to be_invalid

          expect(service.errors.messages_for(:delivery_partner_id)).to include("The entered delivery partner is not recognised to be working in partnership with you for the given cohort. Contact the DfE for more information.")
        end
      end
    end

    context "school funding error" do
      let(:school) { create :school, :cip_only }

      it "returns error" do
        expect(service).to be_invalid

        expect(service.errors.messages_for(:school_id)).to include("The school you have entered has not registered to deliver DfE-funded training. Contact the school for more information.")
      end
    end

    context "school ineligible error" do
      context "eligible school" do
        let(:school) { create :school, :open, administrative_district_code: "E123", school_type_code: 1 }

        it "does not show error" do
          expect(school).to be_eligible
          expect(service).to be_valid
        end
      end

      context "ineligible school" do
        let(:school) { create :school, :closed }

        it "returns error" do
          expect(school).to_not be_eligible
          expect(service).to be_invalid

          expect(service.errors.messages_for(:school_id)).to include("The school you have entered is currently ineligible for DfE funding. Contact the school for more information.")
        end
      end
    end

    context "school already confirmed" do
      let!(:partnership) { create(:partnership, school:, delivery_partner:, lead_provider:, cohort:) }

      it "returns error" do
        expect(service).to be_invalid

        expect(service.errors.messages_for(:school_id)).to include("You are already in a confirmed partnership with this school for the entered cohort.")
      end
    end

    context "recruited by other provider" do
      let(:lead_provider2) { create :lead_provider }
      let!(:partnership) { create(:partnership, school:, delivery_partner:, lead_provider: lead_provider2, cohort:) }

      it "returns error" do
        expect(service).to be_invalid

        expect(service.errors.messages_for(:school_id)).to include("Another provider is in a confirmed partnership with the school for the cohort you entered. Contact the school for more information.")
      end
    end

    context "school has not confirmed their programme" do
      let(:previous_cohort) { create(:cohort, start_year: cohort.start_year - 1) }
      let(:lead_provider2) { create :lead_provider }
      let!(:school_cohort) { create(:school_cohort, :fip, school:, cohort: previous_cohort) }
      let!(:partnership) { create(:partnership, school:, delivery_partner:, lead_provider: lead_provider2, cohort: previous_cohort) }

      it "returns error" do
        expect(service).to be_invalid

        expect(service.errors.messages_for(:school_id)).to include("The school you have entered has not yet confirmed they will deliver DfE-funded training. Contact the school for more information.")
      end
    end

    context "with existing challenged partnership" do
      let(:lead_provider2) { create :lead_provider }
      let!(:partnership) { create(:partnership, :challenged, school:, delivery_partner:, lead_provider: lead_provider2, cohort:) }

      it "creates a new partnership" do
        expect(Partnership.count).to eql(1)
        expect(service).to be_valid
        service.call

        expect(Partnership.count).to eql(2)
        partnership = Partnership.find_by(lead_provider: lead_provider2)
        expect(partnership.cohort_id).to eq(cohort.id)
        expect(partnership.delivery_partner_id).to eq(delivery_partner.id)
        expect(partnership.school_id).to eq(school.id)
      end
    end

    context "existing 'relationship=true' partnership with delivery_partner2" do
      let(:delivery_partner2) { create(:delivery_partner, name: "Second Delivery Partner") }
      let!(:provider_relationship2) { create(:provider_relationship, lead_provider:, delivery_partner: delivery_partner2, cohort:) }
      let!(:partnership2) { create(:partnership, school:, cohort:, delivery_partner: delivery_partner2, lead_provider:, relationship: true) }

      let(:params) do
        {
          cohort: cohort.start_year,
          school_id: school.id,
          lead_provider_id: lead_provider.id,
          delivery_partner_id: delivery_partner2.id,
        }
      end

      it "sets the relationship partnership as the default" do
        expect(service).to be_valid
        expect { service.call }.not_to change(Partnership, :count)

        partnership = Partnership.first
        expect(partnership.cohort_id).to eq(cohort.id)
        expect(partnership.delivery_partner_id).to eq(delivery_partner2.id)
        expect(partnership.lead_provider_id).to eq(lead_provider.id)
        expect(partnership.school_id).to eq(school.id)
        expect(partnership.relationship).to be(false)
      end
    end
  end
end
