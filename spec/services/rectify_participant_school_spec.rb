# frozen_string_literal: true

require "rails_helper"

RSpec.describe RectifyParticipantSchool do
  subject(:service) { described_class }
  let(:cohort) { Cohort[2021] || create(:cohort, start_year: 2021) }
  let(:participant_profile) { create(:ect_participant_profile, cohort:) }
  let(:new_school) { create(:school, name: "Big Shiny School", urn: "123000") }
  let!(:school_cohort) { create(:school_cohort, cohort: participant_profile.school_cohort.cohort, school: new_school) }
  let(:transfer_uplift) { true }

  describe ".call" do
    before do
      service.call(participant_profile:, school: new_school, transfer_pupil_premium_and_sparsity: transfer_uplift)
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
  end
end
