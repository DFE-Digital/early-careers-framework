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
    let(:induction_programme) { create(:induction_programme, partnership:) }
    let!(:induction_record) { create :induction_record, participant_profile:, induction_programme:, training_status: "withdrawn" }

    subject { described_class.new(induction_record) }

    context "#serializable_hash" do
      it "returns valid hash" do
        expect(subject.serializable_hash[:data][:attributes]).to eq(
          full_name: participant_profile.user.full_name,
          email_address: participant_profile.user.email,
          trn: participant_profile.teacher_profile.trn,
          role: participant_profile.role,
          lead_provider: induction_record.lead_provider_name,
          delivery_partner: induction_record.delivery_partner_name,
          school: induction_record.school.name,
          school_unique_reference_number: induction_record.school.urn,
          academic_year: induction_record.cohort.start_year,
          training_status: "withdrawn",
          status: "No longer being trained",
        )
      end

      context "when participant is Mentor and Induction Tutor" do
        let(:participant_profile) { create(:mentor_participant_profile) }

        it "returns Mentor" do
          create(:induction_coordinator_profile, user: participant_profile.user)

          expect(subject.serializable_hash[:data][:attributes][:role]).to eq("Mentor")
        end
      end
    end
  end
end
