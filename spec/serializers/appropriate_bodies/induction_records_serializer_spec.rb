# frozen_string_literal: true

require "rails_helper"

module AppropriateBodies
  RSpec.describe InductionRecordsSerializer do
    let(:appropriate_body) { create(:appropriate_body_local_authority) }
    let(:participant_profile) { create :ect_participant_profile, training_status: "withdrawn" }
    let(:lead_provider) { create(:lead_provider) }
    let(:delivery_partner) { create(:delivery_partner) }
    let(:partnership) do
      create(
        :partnership,
        delivery_partner:,
        lead_provider:,
        challenged_at: nil,
        challenge_reason: nil,
        pending: false,
      )
    end
    let(:induction_programme) { create(:induction_programme, :fip, partnership:) }
    let!(:induction_record) { create :induction_record, participant_profile:, induction_programme:, training_status: "withdrawn" }
    let(:training_record_states) { DetermineTrainingRecordState.call(induction_records: induction_record) }

    subject { described_class.new(induction_record, params: { training_record_states: }) }

    context "#serializable_hash" do
      it "returns valid hash" do
        expect(subject.serializable_hash[:data][:attributes]).to eq(
          full_name: participant_profile.user.full_name,
          trn: participant_profile.teacher_profile.trn,
          school_urn: induction_record.school.urn,
          status: "ECT not currently linked to you",
          induction_type: "FIP",
          induction_tutor: induction_record.school.contact_email,
        )
      end

      context "when the programme_type_changes_2025 feature flag is enabled" do
        before { FeatureFlag.activate(:programme_type_changes_2025) }

        it "returns the correct `induction_type`" do
          expect(subject.serializable_hash[:data][:attributes]).to eq(
            full_name: participant_profile.user.full_name,
            trn: participant_profile.teacher_profile.trn,
            school_urn: induction_record.school.urn,
            status: "ECT not currently linked to you",
            induction_type: "Provider led",
            induction_tutor: induction_record.school.contact_email,
          )
        end
      end
    end
  end
end
