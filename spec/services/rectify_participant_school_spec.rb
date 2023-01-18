# frozen_string_literal: true

require "rails_helper"

RSpec.describe RectifyParticipantSchool do
  subject(:service) { described_class }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:participant_profile) { create(:ect_participant_profile, cohort:) }
  let(:participant_identity) { participant_profile.participant_identity }
  let(:old_school) { participant_profile.school }
  let(:new_school) { create(:school, name: "Big Shiny School", urn: "123000") }
  let!(:school_cohort) { create(:school_cohort, cohort:, school: new_school) }
  let(:transfer_uplift) { true }

  describe ".call" do
    before do
      if participant_profile.mentor?
        old_school.school_mentors.create!(participant_profile:, preferred_identity: participant_identity)
      end

      service.call(participant_profile:,
                   from_school: old_school,
                   to_school: new_school,
                   transfer_pupil_premium_and_sparsity: transfer_uplift)
      participant_profile.reload
    end

    it "moves the participant to the new school" do
      expect(participant_profile.school_cohort).to eq school_cohort
      expect(participant_profile.teacher_profile.school).to eq new_school
    end

    context "when the new school has sparsity uplift" do
      let(:new_school) { create(:school, :sparsity_uplift, name: "Big Shiny School", urn: "123000") }

      it "sets the sparsity uplift flag on the participant profile" do
        expect(participant_profile).to be_sparsity_uplift
      end
    end

    context "when the new school does not have sparsity uplift" do
      let(:participant_profile) { create(:ect_participant_profile, :sparsity_uplift) }

      it "clears the sparsity uplift flag on the participant profile" do
        expect(participant_profile).not_to be_sparsity_uplift
      end
    end

    context "when the new school has pupil premium uplift" do
      let(:new_school) { create(:school, :pupil_premium_uplift, name: "Big Shiny School", urn: "123000") }

      it "sets the pupil premium uplift flag on the participant profile" do
        expect(participant_profile).to be_pupil_premium_uplift
      end
    end

    context "when the new school does not pupil premium uplift" do
      let(:participant_profile) { create(:ect_participant_profile, :pupil_premium_uplift) }

      it "clears the pupil premium uplift flag on the participant profile" do
        expect(participant_profile).not_to be_pupil_premium_uplift
      end
    end

    context "when the transfer_pupil_premium_and_sparsity flag is false" do
      let(:new_school) { create(:school, :pupil_premium_uplift, :sparsity_uplift, name: "Big Shiny School", urn: "123000") }
      let(:transfer_uplift) { false }

      it "does not change the pupil premium uplift flag on the participant profile" do
        expect(participant_profile).not_to be_pupil_premium_uplift
      end

      it "does not change the sparsity uplift flag on the participant profile" do
        expect(participant_profile).not_to be_sparsity_uplift
      end
    end

    context "when the participant is a mentor" do
      let(:participant_profile) { create(:mentor_participant_profile) }

      it "update both schools' mentor pool" do
        expect(old_school.mentor_profiles).not_to include(participant_profile)
        expect(new_school.mentor_profiles).to include(participant_profile)
      end
    end
  end
end
