# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::DeliveryPartnersQuery do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let!(:delivery_partner) do
    create(:delivery_partner, name: "First Delivery Partner").tap do |delivery_partner|
      create(:provider_relationship, cohort:, delivery_partner:, lead_provider:)
    end
  end

  let(:params) { {} }

  subject { described_class.new(lead_provider:, params:) }

  describe "#delivery_partners" do
    let(:another_cohort) { create(:cohort, start_year: "2050") }
    let!(:another_delivery_partner) do
      create(:delivery_partner, name: "Second Delivery Partner").tap do |delivery_partner|
        create(:provider_relationship, cohort: another_cohort, delivery_partner:, lead_provider:)
      end
    end
    let(:pre_2021_cohort) { create(:cohort, start_year: 2020) }
    let!(:pre_2021_delivery_partner) do
      create(:delivery_partner, name: "Pre-2021 Delivery Partner").tap do |delivery_partner|
        create(:provider_relationship, cohort: pre_2021_cohort, delivery_partner:, lead_provider:)
      end
    end

    it "returns all delivery partners" do
      expect(subject.delivery_partners).to match_array([delivery_partner, another_delivery_partner])
    end

    context "with correct cohort filter" do
      let(:params) { { filter: { cohort: pre_2021_cohort.display_name } } }

      it "returns all delivery partners for the specific cohort" do
        expect(subject.delivery_partners).to match_array([pre_2021_delivery_partner])
      end
    end

    context "with multiple cohort filter" do
      let(:params) { { filter: { cohort: [cohort.start_year, 2050].join(",") } } }

      it "returns all delivery partners for the specific cohort" do
        expect(subject.delivery_partners).to match_array([delivery_partner, another_delivery_partner])
      end
    end

    context "with incorrect cohort filter" do
      let(:params) { { filter: { cohort: "2017" } } }

      it "returns no delivery partners" do
        expect(subject.delivery_partners).to be_empty
      end
    end

    context "when delivery_partners belongs in multiple cohorts" do
      before do
        create(:provider_relationship, cohort: another_cohort, delivery_partner:, lead_provider:)
        create(:provider_relationship, cohort:, delivery_partner: another_delivery_partner, lead_provider:)
      end

      it "returns each delivery partner only once" do
        expect(subject.delivery_partners).to match_array([delivery_partner, another_delivery_partner])
      end
    end

    context "sorting" do
      before { another_delivery_partner.update!(created_at: 1.month.ago) }

      it "returns all records ordered by created_at" do
        expect(subject.delivery_partners).to eq([another_delivery_partner, delivery_partner])
      end
    end
  end

  describe "#delivery_partner" do
    context "with correct params" do
      let(:params) { { id: delivery_partner.id } }

      it "returns a specific delivery partners" do
        expect(subject.delivery_partner).to eq(delivery_partner)
      end
    end

    context "with incorrect params" do
      let(:params) { { id: SecureRandom.uuid } }

      it "returns no delivery partner" do
        expect { subject.delivery_partner }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with no params" do
      it "returns no delivery partner" do
        expect { subject.delivery_partner }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
