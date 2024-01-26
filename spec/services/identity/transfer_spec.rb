# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Transfer do
  subject(:service) { described_class }

  describe ".call" do
    let(:id1) { create(:participant_identity) }
    let(:id2) { create(:participant_identity) }
    let(:user1) { id1.user }
    let(:user2) { id2.user }

    it "moves the participant identity record from one user to another" do
      service.call(from_user: user1, to_user: user2)
      expect(user1.participant_identities.count).to be_zero
      expect(user2.participant_identities.count).to eq 2
    end

    context "when participant profiles are attached to the user" do
      let(:school_cohort) { create(:school_cohort) }
      let(:teacher_profile1) { create(:teacher_profile, user: user1) }
      let!(:participant_profile) { create(:ect_participant_profile, teacher_profile: teacher_profile1, school_cohort:) }

      context "when the receiver does not have a teacher_profile" do
        it "creates a teacher_profile for the user" do
          expect {
            service.call(from_user: user1, to_user: user2)
          }.to change { TeacherProfile.count }.by(1)
        end

        it "moves the participant_profiles to the new teacher_profile" do
          service.call(from_user: user1, to_user: user2)
          expect(user2.teacher_profile.participant_profiles).to match_array [participant_profile]
        end
      end

      context "when the receiver has a teacher_profile" do
        let!(:teacher_profile2) { create(:teacher_profile, user: user2) }

        it "moves the participant_profiles to the teacher_profile" do
          service.call(from_user: user1, to_user: user2)
          expect(user2.teacher_profile.participant_profiles).to match_array [participant_profile]
        end
      end

      context "when the previous user has declarations" do
        let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
        let!(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider, user: user1) }
        let!(:declaration) { create(:ect_participant_declaration, participant_profile:, user: user1, cpd_lead_provider:) }
        let!(:another_participant_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider, user: user1) }
        let!(:another_declaration) { create(:mentor_participant_declaration, participant_profile: another_participant_profile, user: user1, cpd_lead_provider:) }

        it "moves the declarations to the new user" do
          service.call(from_user: user1, to_user: user2)

          expect(declaration.reload.user).to eq(user2)
          expect(another_declaration.reload.user).to eq(user2)
        end
      end
    end

    context "when the from user is an induction coordinator" do
      let(:from_school) { create(:school) }
      let!(:from_user_sit_profile) { create(:induction_coordinator_profile, user: user1, schools: [from_school]) }

      before do
        service.call(from_user: user1, to_user: user2)
        user1.reload
      end

      context "when the destination user is also an induction coordinator" do
        let(:to_school) { create(:school) }
        let!(:to_user_sit_profile) { create(:induction_coordinator_profile, user: user2, schools: [to_school]) }

        it "transfers the schools to the new user" do
          expect(user2.schools).to match_array [from_school, to_school]
          expect(user1.schools).to be_empty
        end
      end

      context "when the destination user is not an induction coordinator" do
        it "transfers the induction coordinator profile" do
          expect(user2).to be_induction_coordinator
          expect(user1).not_to be_induction_coordinator
        end

        it "transfers the schools to the new user" do
          expect(user2.schools).to match_array [from_school]
        end
      end
    end

    context "when the user has a get_an_identity_id" do
      let(:get_an_identity_id) { SecureRandom.uuid }

      it "transfers the ID to the new user" do
        user1.update!(get_an_identity_id:)
        service.call(from_user: user1, to_user: user2)
        expect(user1.get_an_identity_id).to be_nil
        expect(user2.get_an_identity_id).to eq get_an_identity_id
      end

      context "when the destination user has a get_an_identity_id" do
        it "does not overwrite it with nil" do
          user2.update!(get_an_identity_id:)
          service.call(from_user: user1, to_user: user2)
          expect(user1.get_an_identity_id).to be_nil
          expect(user2.get_an_identity_id).to eq get_an_identity_id
        end
      end

      context "when both the source and destination users have a get_an_identity_id" do
        let(:get_an_identity_id_2) { SecureRandom.uuid }

        before do
          user1.update!(get_an_identity_id:)
          user2.update!(get_an_identity_id: get_an_identity_id_2)
        end

        it "raises an error" do
          expect {
            service.call(from_user: user1, to_user: user2)
          }.to raise_error(Identity::TransferError, "Identity ids present on both User records: #{user1.id} -> #{user2.id}")
        end
      end
    end

    context "create participant_id_changes" do
      it "creates a participant_id_change for user2" do
        expect(ParticipantIdChange.count).to eql(0)
        service.call(from_user: user1, to_user: user2)

        expect(ParticipantIdChange.count).to eql(1)
        rec = ParticipantIdChange.first
        expect(rec.from_participant).to eql(user1)
        expect(rec.to_participant).to eql(user2)
        expect(rec.user).to eql(user2)
      end

      context "with existing participant_id_changes" do
        let(:previous_user) { create(:user) }
        let!(:previous_change) { create(:participant_id_change, from_participant: previous_user, to_participant: user1, user: user1) }

        it "moves previous participant_id_change to user2" do
          expect(ParticipantIdChange.count).to eql(1)
          rec = ParticipantIdChange.first
          expect(rec.from_participant).to eql(previous_user)
          expect(rec.to_participant).to eql(user1)
          expect(rec.user).to eql(user1)

          service.call(from_user: user1, to_user: user2)
          expect(ParticipantIdChange.count).to eql(2)

          rec1, rec2 = ParticipantIdChange.order(:created_at).to_a
          expect(rec1.from_participant).to eql(previous_user)
          expect(rec1.to_participant).to eql(user1)
          expect(rec1.user).to eql(user2)

          expect(rec2.from_participant).to eql(user1)
          expect(rec2.to_participant).to eql(user2)
          expect(rec2.user).to eql(user2)
        end
      end

      context "run transfer multiple times" do
        it "should only create one participant_id_change" do
          expect(ParticipantIdChange.count).to eql(0)
          service.call(from_user: user1, to_user: user2)
          expect(ParticipantIdChange.count).to eql(1)
          service.call(from_user: user1, to_user: user2)
          expect(ParticipantIdChange.count).to eql(1)
        end
      end
    end
  end
end
