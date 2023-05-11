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
  end
end
