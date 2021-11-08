# frozen_string_literal: true

require "rails_helper"

RSpec.describe SetParticipantCategories do
  describe "#run" do
    subject(:service) { described_class }

    let!(:eligible_ect) { create(:participant_profile, :ect, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: school_cohort) }
    let!(:ineligible_mentor) { create(:participant_profile, :mentor, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: school_cohort) }
    let!(:contacted_for_info_ect) { create(:participant_profile, :ect, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort: school_cohort) }
    let!(:ero_mentor) { create(:participant_profile, :mentor, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: school_cohort) }
    let!(:details_being_checked_ect) { create(:participant_profile, :ect, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: school_cohort) }

    context "CIP cohorts" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      let(:cip_eligible_participants) { [eligible_ect, ineligible_mentor, ero_mentor, details_being_checked_ect] }
      let(:cip_ineligible_participants) { [] }
      let(:cip_contacted_for_info_participants) { [contacted_for_info_ect] }
      let(:cip_details_being_checked_participants) { [] }

      before do
        FeatureFlag.activate(:eligibility_notifications)

        ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
        ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
        details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")

        @participant_categories = service.call(school_cohort, induction_coordinator.user)
      end

      it "returns eligible, ineligible and details_being_checked participants in eligible category" do
        expect(@participant_categories.eligible).to match_array(cip_eligible_participants)
      end

      it "does not return participants in ineligible category" do
        expect(@participant_categories.ineligible).to match_array(cip_ineligible_participants)
      end

      it "returns contacted_for_info participants in contacted_for_info category" do
        expect(@participant_categories.contacted_for_info).to match_array(cip_contacted_for_info_participants)
      end

      it "does not return participants in details_being_checked category" do
        expect(@participant_categories.details_being_checked).to match_array(cip_details_being_checked_participants)
      end
    end

    context "FIP cohorts with active eligibility_notifications feature flag" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      let(:fip_eligible_participants) { [eligible_ect, ero_mentor] }
      let(:fip_ineligible_participants) { [ineligible_mentor] }
      let(:fip_contacted_for_info_participants) { [contacted_for_info_ect] }
      let(:fip_details_being_checked_participants) { [details_being_checked_ect] }

      before do
        FeatureFlag.activate(:eligibility_notifications)

        ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
        ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
        details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")

        @participant_categories = service.call(school_cohort, induction_coordinator.user)
      end

      it "returns eligible participants in eligible category" do
        expect(@participant_categories.eligible).to match_array(fip_eligible_participants)
      end

      it "returns ineligible participants in ineligible category" do
        expect(@participant_categories.ineligible).to match_array(fip_ineligible_participants)
      end

      it "returns contacted_for_info participants in contacted_for_info category" do
        expect(@participant_categories.contacted_for_info).to match_array(fip_contacted_for_info_participants)
      end

      it "returns details_being_checked participants in details_being_checked category" do
        expect(@participant_categories.details_being_checked).to match_array(fip_details_being_checked_participants)
      end
    end

    context "FIP cohorts with inactive eligibility_notifications feature flag" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      let(:fip_eligible_participants) { [] }
      let(:fip_ineligible_participants) { [] }
      let(:fip_contacted_for_info_participants) { [contacted_for_info_ect] }
      let(:fip_details_being_checked_participants) { [eligible_ect, ineligible_mentor, ero_mentor, details_being_checked_ect] }

      before do
        FeatureFlag.deactivate(:eligibility_notifications)

        ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
        ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
        details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")

        @participant_categories = service.call(school_cohort, induction_coordinator.user)
      end

      it "does not return participants in eligible category" do
        expect(@participant_categories.eligible).to match_array(fip_eligible_participants)
      end

      it "does not return participants in ineligible category" do
        expect(@participant_categories.ineligible).to match_array(fip_ineligible_participants)
      end

      it "returns contacted_for_info participants in contacted_for_info category" do
        expect(@participant_categories.contacted_for_info).to match_array(fip_contacted_for_info_participants)
      end

      it "returns details_being_checked, ineligible and eligible participants in details_being_checked category" do
        expect(@participant_categories.details_being_checked).to match_array(fip_details_being_checked_participants)
      end
    end
  end
end
