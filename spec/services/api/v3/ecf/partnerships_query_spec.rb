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
    let(:pre_2021_cohort) { create(:cohort, start_year: 2020) }
    let!(:pre_2021_partnership) { create(:partnership, cohort: pre_2021_cohort, lead_provider:) }

    it "returns all partnerships" do
      expect(subject.partnerships).to match_array([partnership, another_partnership])
    end

    describe "cohort filter" do
      context "with correct value" do
        let(:params) { { filter: { cohort: pre_2021_cohort.display_name } } }

        it "returns all partnerships for the specific cohort" do
          expect(subject.partnerships).to match_array([pre_2021_partnership])
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
      let!(:partnership) { create(:partnership, cohort:, lead_provider:) }
      let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:) }

      let(:user1) { create(:participant_identity).user }
      let(:user2) { create(:participant_identity).user }
      let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, user: user1, schools: [partnership.school]) }
      let!(:induction_coordinator_profile2) { create(:induction_coordinator_profile, user: user2, schools: [another_partnership.school]) }

      before do
        [
          partnership,
          partnership.school,
          partnership.delivery_partner,
          partnership.school.induction_coordinators.first,
        ].each do |rec|
          rec.update!(updated_at: 2.days.ago)
        end

        [
          another_partnership,
          another_partnership.school,
          another_partnership.delivery_partner,
          another_partnership.school.induction_coordinators.first,
        ].each do |rec|
          rec.update!(updated_at: 5.days.ago)
        end
      end

      context "with latest partnership.updated_at" do
        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }
        before do
          partnership.update!(updated_at: 1.hour.ago)
        end
        it "returns correct partnership" do
          expect(subject.partnerships).to match_array([partnership])
        end
      end

      context "with latest school.updated_at" do
        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }
        before do
          another_partnership.school.update!(updated_at: 1.hour.ago)
        end
        it "returns correct partnership" do
          expect(subject.partnerships).to match_array([another_partnership])
        end
      end

      context "with latest delivery_partner.updated_at" do
        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }
        before do
          partnership.delivery_partner.update!(updated_at: 1.hour.ago)
        end
        it "returns correct partnership" do
          expect(subject.partnerships).to match_array([partnership])
        end
      end

      context "with induction_coordinators.first.first.updated_at" do
        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }
        before do
          another_partnership.school.induction_coordinators.first.update!(updated_at: 1.hour.ago)
        end
        it "returns correct partnership" do
          expect(subject.partnerships).to match_array([another_partnership])
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

    describe "sorting" do
      let!(:another_partnership) do
        travel_to(2.days.ago) do
          create(:partnership, cohort: another_cohort, lead_provider:)
        end
      end

      context "when no sort parameter is specified" do
        it "returns all records ordered by created_at ascending by default" do
          expect(subject.partnerships).to eq([another_partnership, partnership])
        end
      end

      context "when created_at sort parameter is specified" do
        let(:params) { { sort: "-created_at" } }

        it "returns records in the correct order" do
          expect(subject.partnerships).to eq([partnership, another_partnership])
        end
      end

      context "when updated_at sort parameter is specified" do
        let(:params) { { sort: "updated_at" } }

        it "returns records in the correct order" do
          expect(subject.partnerships).to eq([another_partnership, partnership])
        end
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
