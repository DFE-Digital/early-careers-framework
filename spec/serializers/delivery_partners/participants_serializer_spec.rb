# frozen_string_literal: true

require "rails_helper"

module DeliveryPartners
  RSpec.describe ParticipantsSerializer do
    let(:school) { create(:school) }
    let(:school_cohort) { create(:school_cohort, school:) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort:, training_status: "withdrawn") }

    let(:lead_provider) { create(:lead_provider) }
    let(:delivery_partner_user) { create(:user, :delivery_partner) }
    let(:delivery_partner) { delivery_partner_user.delivery_partner_profile.delivery_partner }
    let(:partnership) do
      create(
        :partnership,
        school:,
        delivery_partner:,
        challenged_at: nil,
        challenge_reason: nil,
        pending: false,
        lead_provider:,
      )
    end

    let(:induction_programme) { create(:induction_programme, :fip, partnership:, school_cohort:) }
    let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:, training_status: "withdrawn") }

    let!(:prev_cohort_year) { create(:cohort, start_year: 2020) }

    subject { described_class.new(participant_profile, params: { delivery_partner: }) }

    context "#serializable_hash" do
      it "returns valid hash" do
        expect(subject.serializable_hash[:data][:attributes]).to eq(
          full_name: participant_profile.user.full_name,
          email_address: participant_profile.user.email,
          trn: participant_profile.teacher_profile.trn,
          role: participant_profile.role,
          lead_provider: lead_provider.name,
          school: school.name,
          school_unique_reference_number: school.urn,
          academic_year: school_cohort.cohort.start_year,
          training_status: "withdrawn",
          status: "No longer being trained",
        )
      end

      context "when participant is Mentor and Induction Tutor" do
        let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }

        it "returns Mentor" do
          create(:induction_coordinator_profile, user: participant_profile.user)

          expect(subject.serializable_hash[:data][:attributes][:role]).to eq("Mentor")
        end
      end
    end
  end
end
