# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Transfer do
  subject(:service) { described_class }

  describe ".call" do
    let(:id1) { create(:identity) }
    let(:id2) { create(:identity) }
    let(:user1) { id1.user }
    let(:user2) { id2.user }

    it "moves the participant identity record from one user to another" do
      service.call(from_user: user1, to_user: user2)
      expect(user1.identities.count).to be_zero
      expect(user2.identities.count).to eq 2
    end

    context "when profiles are attached to the user" do
      let(:school_cohort) { create(:school_cohort) }
      let(:teacher_profile1) { create(:teacher_profile, user: user1) }
      let!(:participant_profile) { create(:ecf_participant_profile, teacher_profile: teacher_profile1, school_cohort: school_cohort) }

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
  end
end
