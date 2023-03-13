# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::WithEctsWithNoMentorQuery do
  describe "#call" do
    subject { described_class.new.call }

    context "when there are participants with mentor assigned" do
      let!(:mentor_profile) { create(:seed_mentor_participant_profile, :valid) }
      let!(:participant_profile) { create(:seed_ect_participant_profile, :valid, mentor_profile:) }
      let!(:eligibility) { create(:seed_ecf_participant_eligibility, participant_profile:) }
      let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:) }
      let!(:seed_induction_coordinator_profiles_school) { create(:seed_induction_coordinator_profiles_school, :valid, school: induction_record.school) }

      it "do not include them" do
        expect(subject).not_to include(induction_record.school)
      end
    end

    context "when there are participants with withdrawn induction status" do
      let!(:participant_profile) { create(:seed_ect_participant_profile, :valid, status: :withdrawn) }
      let!(:eligibility) { create(:seed_ecf_participant_eligibility, participant_profile:) }
      let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:) }
      let!(:seed_induction_coordinator_profiles_school) { create(:seed_induction_coordinator_profiles_school, :valid, school: induction_record.school) }

      it "do not include them" do
        expect(subject).not_to include(induction_record.school)
      end
    end

    context "when there are participants with withdrawn training induction status" do
      let!(:participant_profile) { create(:seed_ect_participant_profile, :valid, training_status: :withdrawn) }
      let!(:eligibility) { create(:seed_ecf_participant_eligibility, participant_profile:) }
      let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:) }
      let!(:seed_induction_coordinator_profiles_school) { create(:seed_induction_coordinator_profiles_school, :valid, school: induction_record.school) }

      it "do not include them" do
        expect(subject).not_to include(induction_record.school)
      end
    end

    context "when there are participants with deferred training induction status" do
      let!(:participant_profile) { create(:seed_ect_participant_profile, :valid, training_status: :deferred) }
      let!(:eligibility) { create(:seed_ecf_participant_eligibility, participant_profile:) }
      let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:) }
      let!(:seed_induction_coordinator_profiles_school) { create(:seed_induction_coordinator_profiles_school, :valid, school: induction_record.school) }

      it "do not include them" do
        expect(subject).not_to include(induction_record.school)
      end
    end

    context "when there are active participants :ineligible and with no mentor associated" do
      let!(:participant_profile) { create(:seed_ect_participant_profile, :valid) }
      let!(:eligibility) { create(:seed_ecf_participant_eligibility, :ineligible, participant_profile:) }
      let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:) }
      let!(:seed_induction_coordinator_profiles_school) { create(:seed_induction_coordinator_profiles_school, :valid, school: induction_record.school) }

      it "do not include them" do
        expect(subject).not_to include(induction_record.school)
      end
    end

    context "when there are active participants on :matched eligibility and no mentor associated" do
      let!(:participant_profile) { create(:seed_ect_participant_profile, :valid) }
      let!(:eligibility) { create(:seed_ecf_participant_eligibility, participant_profile:, status: :matched) }
      let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:) }
      let!(:seed_induction_coordinator_profiles_school) { create(:seed_induction_coordinator_profiles_school, :valid, school: induction_record.school) }

      it "include them" do
        expect(subject).to include(induction_record.school => [participant_profile])
      end
    end

    context "when there are active participants on :manual-check eligibility and no mentor associated" do
      let!(:participant_profile) { create(:seed_ect_participant_profile, :valid) }
      let!(:eligibility) { create(:seed_ecf_participant_eligibility, :manual_check, participant_profile:) }
      let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:) }
      let!(:seed_induction_coordinator_profiles_school) { create(:seed_induction_coordinator_profiles_school, :valid, school: induction_record.school) }

      it "include them" do
        expect(subject).to include(induction_record.school => [participant_profile])
      end
    end
  end
end
