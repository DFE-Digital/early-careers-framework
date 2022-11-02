# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ECF::ParticipantsQuery do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:partnership) { create(:partnership, lead_provider:, cohort:) }
  let(:participant_profile) { create(:ecf_participant_profile) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership:) }
  let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile:) }

  let(:params) { {} }

  subject { described_class.new(lead_provider:, params:) }

  describe "#induction_records" do
    it "returns all induction records" do
      expect(subject.induction_records).to match_array([induction_record])
    end

    describe "cohort filter" do
      context "with correct value" do
        let(:params) { { filter: { cohort: "2021" } } }

        it "returns all induction records for the specific cohort" do
          expect(subject.induction_records).to match_array([induction_record])
        end
      end

      context "with multiple values" do
        let(:another_cohort) { create(:cohort, start_year: "2050") }
        let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:) }
        let(:another_participant_profile) { create(:ecf_participant_profile) }
        let(:another_induction_programme) { create(:induction_programme, :fip, partnership: another_partnership) }
        let!(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile) }

        let(:params) { { filter: { cohort: "2021,2050" } } }

        it "returns all induction records for the specific cohort" do
          expect(subject.induction_records).to match_array([induction_record, another_induction_record])
        end
      end

      context "with incorrect value" do
        let(:params) { { filter: { cohort: "2017" } } }

        it "returns no induction records" do
          expect(subject.induction_records).to be_empty
        end
      end
    end

    describe "updated_since filter" do
      context "with correct value" do
        let(:another_participant_profile) { create(:ecf_participant_profile) }
        let(:another_induction_programme) { create(:induction_programme, :fip, partnership:) }
        let!(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile) }

        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }

        before { another_participant_profile.user.update(updated_at: 4.days.ago.iso8601) }

        it "returns all induction_records for the specific updated_since filter" do
          expect(subject.induction_records).to match_array([induction_record])
        end
      end
    end
  end

  describe "#induction_record" do
    describe "id filter" do
      context "with correct value" do
        let(:another_participant_profile) { create(:ecf_participant_profile) }
        let(:another_induction_programme) { create(:induction_programme, :fip, partnership:) }
        let!(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile) }

        let(:params) { { id: another_participant_profile.participant_identity.external_identifier } }

        it "returns a specific induction record" do
          expect(subject.induction_record).to eql(another_induction_record)
        end
      end

      context "with incorrect value" do
        let(:params) { { id: SecureRandom.uuid } }

        it "raises an error" do
          expect {
            subject.induction_record
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
