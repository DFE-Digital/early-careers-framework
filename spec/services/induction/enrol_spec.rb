# frozen_string_literal: true

RSpec.describe Induction::Enrol do
  describe "#call" do
    let(:school_cohort) { create :school_cohort, appropriate_body: create(:appropriate_body_local_authority) }
    let!(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:teacher_profile) { create(:teacher_profile) }
    let(:participant_profile) { create(:ect_participant_profile, teacher_profile:, school_cohort:) }

    subject(:service) { described_class }

    it "creates an induction record for the given programme" do
      expect { service.call(participant_profile:, induction_programme:) }.to change { induction_programme.induction_records.count }.by 1
    end

    it "creates a participant_profile_state" do
      expect { subject.call(participant_profile:, induction_programme:) }.to change { ParticipantProfileState.count }.by(1)
    end

    context "when the participant profile training_status is withdrawn" do
      let(:participant_profile) { create(:ect_participant_profile, training_status: :withdrawn) }

      it "it changes it to active" do
        service.call(participant_profile:, induction_programme:)
        expect(participant_profile.training_status).to eql "active"
      end
    end

    context "without optional params" do
      let(:induction_record) do
        service.call(participant_profile:, induction_programme:)
      end

      it "sets the start_date to the schedule start_date" do
        expect(induction_record.start_date).to eq(participant_profile.schedule.milestones.first.start_date)
      end

      it "sets the preferred identity to be the participant_profile.participant_identity" do
        expect(induction_record.preferred_identity_id).to eq(participant_profile.participant_identity_id)
      end

      it "sets the appropriate body the default one from the school cohort of the induction programme" do
        expect(induction_record.appropriate_body_id).to eq(school_cohort.appropriate_body_id)
      end
    end

    context "when a mentor_profile is provided" do
      let(:mentor_profile) { create(:mentor_participant_profile) }

      let(:induction_record) do
        service.call(participant_profile:,
                     induction_programme:,
                     mentor_profile:)
      end

      it "sets the mentor for the participant" do
        expect(induction_record.mentor_profile).to eq mentor_profile
      end
    end

    context "when a start_date is provided" do
      let(:start_date) { 1.week.from_now }
      let(:induction_record) do
        service.call(participant_profile:,
                     induction_programme:,
                     start_date:)
      end

      it "sets the start_date" do
        expect(induction_record.start_date).to be_within(1.second).of(start_date)
      end
    end

    context "when a preferred email is provided" do
      let(:preferred_email) { "newemail@example.com" }

      let(:induction_record) do
        service.call(participant_profile:,
                     induction_programme:,
                     preferred_email:)
      end

      it "adds a new identity to the user" do
        expect { induction_record }.to change { participant_profile.participant_identity.user.participant_identities.count }.by 1
      end

      it "sets the preferred identity" do
        expect(induction_record.preferred_identity.email).to eq(preferred_email)
      end
    end
  end
end
