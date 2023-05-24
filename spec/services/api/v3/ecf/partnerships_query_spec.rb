# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ECF::PartnershipsQuery do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let!(:partnership) { create(:partnership, cohort:, lead_provider:) }

  let(:params) { {} }

  subject { described_class.new(lead_provider:, params:) }

  describe "#partnerships" do
    let(:another_cohort) { create(:cohort, start_year: "2050") }
    let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:) }

    it "returns all partnerships" do
      expect(subject.partnerships).to match_array([partnership, another_partnership])
    end

    describe "cohort filter" do
      context "with correct value" do
        let(:params) { { filter: { cohort: cohort.display_name } } }

        it "returns all partnerships for the specific cohort" do
          expect(subject.partnerships).to match_array([partnership])
        end
      end

      context "with multiple values" do
        let(:params) { { filter: { cohort: [cohort.display_name, another_cohort.display_name].join(",") } } }

        it "returns all partnerships for the specific cohort" do
          expect(subject.partnerships).to match_array([partnership, another_partnership])
        end
      end

      context "with incorrect value" do
        let(:params) { { filter: { cohort: "2017" } } }

        it "returns no partnerships" do
          expect(subject.partnerships).to be_empty
        end
      end
    end

    describe "updated_since filter" do
      context "with correct value" do
        let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:, updated_at: 2.days.ago.iso8601) }

        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }

        it "returns all partnerships for the specific cohort" do
          expect(subject.partnerships).to match_array([partnership])
        end
      end
    end

    describe "delivery_partner_id filter" do
      context "with correct value" do
        let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:, updated_at: 2.days.ago.iso8601) }

        let(:params) { { filter: { delivery_partner_id: partnership.delivery_partner_id } } }

        it "returns all partnerships for the specific delivery partner" do
          expect(subject.partnerships).to match_array([partnership])
        end
      end

      context "with multiple values" do
        let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:, updated_at: 2.days.ago.iso8601) }

        let(:params) { { filter: { delivery_partner_id: "#{partnership.delivery_partner_id},#{another_partnership.delivery_partner_id}" } } }

        it "returns all partnerships for the specific delivery partner" do
          expect(subject.partnerships).to match_array([partnership, another_partnership])
        end
      end

      context "with incorrect value" do
        let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:, updated_at: 2.days.ago.iso8601) }

        let(:params) { { filter: { delivery_partner_id: SecureRandom.uuid } } }

        it "returns no partnerships" do
          expect(subject.partnerships).to be_empty
        end
      end
    end

    describe "ignore relationships" do
      let(:relationship_cohort) { create(:cohort, start_year: "2051") }
      let!(:relationship_partnership) { create(:partnership, cohort: relationship_cohort, lead_provider:, relationship: true) }

      it "does not return relationship" do
        expect(subject.partnerships).to match_array([partnership, another_partnership])
      end
    end

    context "sorting" do
      let!(:another_partnership) do
        travel_to(2.days.ago) do
          create(:partnership, cohort: another_cohort, lead_provider:)
        end
      end

      it "returns all partnerships ordered by created_at" do
        expect(subject.partnerships).to eq([another_partnership, partnership])
      end
    end
  end

  describe "#partnership" do
    context "when partnership ID belongs to CPD lead provider" do
      let(:params) { { id: partnership.id } }

      it "returns the partnership with the id" do
        expect(subject.partnership).to eq(partnership)
      end
    end

    context "when partnership ID belongs to another CPD lead provider" do
      let(:partnership) { create(:partnership, cohort:) }
      let(:params) { { id: partnership.id } }

      it "does not return the partnership" do
        expect { subject.partnership }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with non-existing ID" do
      let(:params) { { id: "does-not-exist" } }

      it "raises an exception" do
        expect { subject.partnership }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with no ID" do
      let(:params) { {} }

      it "raises an exception" do
        expect { subject.partnership }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "ignore relationships" do
      let!(:partnership) { create(:partnership, cohort:, lead_provider:, relationship: true) }
      let(:params) { { id: partnership.id } }

      it "does not return relationship" do
        expect { subject.partnership }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
