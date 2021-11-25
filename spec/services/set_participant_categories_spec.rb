# frozen_string_literal: true

require "rails_helper"

RSpec.describe SetParticipantCategories do
  describe "#run" do
    subject(:service) { described_class }

    let!(:eligible_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: school_cohort) }
    let!(:ineligible_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: school_cohort) }
    let!(:contacted_for_info_ect) { create(:ect_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort: school_cohort) }
    let!(:ero_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: school_cohort) }
    let!(:details_being_checked_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: school_cohort) }
    let!(:primary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :primary_profile, school_cohort: school_cohort) }
    let!(:secondary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :secondary_profile, school_cohort: school_cohort) }
    let!(:withdrawn_ect) { create(:participant_profile, :ect, :ecf_participant_eligibility, :ecf_participant_validation_data, training_status: "withdrawn", school_cohort: school_cohort) }

    before do
      [primary_mentor, secondary_mentor].each do |profile|
        profile.ecf_participant_eligibility.determine_status
        profile.ecf_participant_eligibility.save!
      end
    end

    context "SIT for multiple schools" do
      let(:school_cohorts) { create_list(:school_cohort, 3, :cip) }
      let(:school_cohort) { school_cohorts.first }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: school_cohorts.map(&:school)) }

      before do
        @ects = []
        school_cohorts.each do |a_school_cohort|
          @ects << create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: a_school_cohort)
        end
      end

      it "only returns participants for the selected school cohort" do
        participant_categories = service.call(school_cohort, induction_coordinator.user)
        expect(participant_categories.eligible).to match_array [eligible_ect, ineligible_mentor, ero_mentor, details_being_checked_ect, primary_mentor, secondary_mentor, @ects.first]
        expect(participant_categories.eligible).not_to include(@ects[1], @ects[2])
      end
    end

    context "CIP cohorts" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      let(:cip_eligible_participants) { [eligible_ect, ineligible_mentor, ero_mentor, details_being_checked_ect, primary_mentor, secondary_mentor] }
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

      it "returns participants in withdrawn category" do
        expect(@participant_categories.withdrawn).to match_array(withdrawn_participants)
      end
    end

    context "FIP cohorts with active eligibility_notifications feature flag" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      let(:fip_eligible_participants) { [eligible_ect, ero_mentor, primary_mentor, secondary_mentor] }
      let(:fip_ineligible_participants) { [ineligible_mentor] }
      let(:fip_contacted_for_info_participants) { [contacted_for_info_ect] }
      let(:fip_details_being_checked_participants) { [details_being_checked_ect] }
      let(:withdrawn_participants) { [withdrawn_ect] }

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

      it "returns withdrawn participants in withdrawn category" do
        expect(@participant_categories.withdrawn).to match_array(withdrawn_participants)
      end
    end

    context "FIP cohorts with inactive eligibility_notifications feature flag" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      let(:fip_eligible_participants) { [] }
      let(:fip_ineligible_participants) { [] }
      let(:fip_contacted_for_info_participants) { [contacted_for_info_ect] }
      let(:fip_details_being_checked_participants) { [eligible_ect, ineligible_mentor, ero_mentor, details_being_checked_ect, primary_mentor, secondary_mentor] }
      let(:withdrawn_participants) { [withdrawn_ect] }

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

      it "returns details_being_checked, ineligible and eligible participants in details_being_checked category" do
        expect(@participant_categories.withdrawn).to match_array(withdrawn_participants)
      end
    end
  end
end
