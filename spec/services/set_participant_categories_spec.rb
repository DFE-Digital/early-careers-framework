# frozen_string_literal: true

require "rails_helper"

RSpec.describe SetParticipantCategories do
  describe "#run" do
    subject(:service) { described_class }

    let!(:eligible_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:eligible_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:ineligible_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:ineligible_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:contacted_for_info_ect) { create(:ect_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort:) }
    let!(:contacted_for_info_mentor) { create(:mentor_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort:) }
    let!(:ero_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:ero_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:details_being_checked_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:details_being_checked_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:primary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :primary_profile, school_cohort:) }
    let!(:secondary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :secondary_profile, school_cohort:) }
    let!(:withdrawn_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, training_status: "withdrawn", school_cohort:) }
    let!(:transferring_in_participant) { create(:ecf_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:transferring_out_participant) { create(:ecf_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:ect_no_qts) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:mentor_no_qts) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let!(:induction_programme) { create(:induction_programme, school_cohort:) }

    before do
      [primary_mentor, secondary_mentor].each do |profile|
        Participants::DetermineEligibilityStatus.call(ecf_participant_eligibility: profile.ecf_participant_eligibility)
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

      it "only returns ECTs for the selected school cohort" do
        ect_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::ECT")

        expect(ect_categories.eligible).to match_array [eligible_ect, ineligible_ect, ero_ect, details_being_checked_ect, ect_no_qts, @ects.first]
        expect(ect_categories.eligible).not_to include(@ects[1], @ects[2], eligible_mentor, ero_mentor)
      end

      it "only returns mentors for the selected school cohort" do
        mentor_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::Mentor")

        expect(mentor_categories.eligible).to match_array [eligible_mentor, ineligible_mentor, ero_mentor, details_being_checked_mentor, mentor_no_qts, primary_mentor, secondary_mentor]
        expect(mentor_categories.eligible).not_to include(@ects[1], @ects[2], eligible_ect, ero_ect)
      end
    end

    context "CIP cohorts" do
      let(:school_cohort) { create(:school_cohort, :cip) }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      let(:cip_eligible_ects) { [eligible_ect, ineligible_ect, ero_ect, details_being_checked_ect, ect_no_qts] }
      let(:cip_eligible_mentors) { [eligible_mentor, ineligible_mentor, ero_mentor, details_being_checked_mentor, primary_mentor, secondary_mentor, mentor_no_qts] }
      let(:cip_ineligible_ects) { [] }
      let(:cip_ineligible_mentors) { [] }
      let(:cip_contacted_for_info_ects) { [contacted_for_info_ect] }
      let(:cip_contacted_for_info_mentors) { [contacted_for_info_mentor] }
      let(:cip_details_being_checked_ects) { [] }
      let(:cip_details_being_checked_mentors) { [] }
      let(:cip_no_qts_ect) { [] }
      let(:cip_no_qts_mentor) { [] }
      let(:withdrawn_ects) { [withdrawn_ect] }

      before do
        FeatureFlag.activate(:eligibility_notifications)

        ineligible_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
        ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
        ero_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
        ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
        details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
        details_being_checked_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
        ect_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
        mentor_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")

        @ect_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::ECT")
        @mentor_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::Mentor")
      end

      it "returns eligible, ineligible and details_being_checked participants in eligible category" do
        expect(@ect_categories.eligible).to match_array(cip_eligible_ects)
        expect(@mentor_categories.eligible).to match_array(cip_eligible_mentors)
      end

      it "does not return participants in ineligible category" do
        expect(@ect_categories.ineligible).to match_array(cip_ineligible_ects)
        expect(@mentor_categories.ineligible).to match_array(cip_ineligible_mentors)
      end

      it "returns contacted_for_info participants in contacted_for_info category" do
        expect(@ect_categories.contacted_for_info).to match_array(cip_contacted_for_info_ects)
        expect(@mentor_categories.contacted_for_info).to match_array(cip_contacted_for_info_mentors)
      end

      it "does not return participants in details_being_checked category" do
        expect(@ect_categories.details_being_checked).to match_array(cip_details_being_checked_ects)
        expect(@mentor_categories.details_being_checked).to match_array(cip_details_being_checked_mentors)
      end

      it "does not return participants in no_qts_participants category" do
        expect(@ect_categories.no_qts_participants).to match_array(cip_no_qts_ect)
        expect(@mentor_categories.no_qts_participants).to match_array(cip_no_qts_mentor)
      end

      it "returns participants in withdrawn category" do
        expect(@ect_categories.withdrawn).to match_array(withdrawn_ect)
      end
    end

    context "FIP cohorts with active eligibility_notifications feature flag" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      let(:fip_eligible_ects) { [eligible_ect, ero_ect] }
      let(:fip_eligible_mentors) { [eligible_mentor, ero_mentor, primary_mentor, secondary_mentor] }
      let(:fip_ineligible_ects) { [ineligible_ect] }
      let(:fip_ineligible_mentors) { [ineligible_mentor] }
      let(:fip_contacted_for_info_ects) { [contacted_for_info_ect] }
      let(:fip_contacted_for_info_mentors) { [contacted_for_info_mentor] }
      let(:fip_details_being_checked_ects) { [details_being_checked_ect] }
      let(:fip_details_being_checked_mentors) { [details_being_checked_mentor] }
      let(:withdrawn_ects) { [withdrawn_ect] }
      let(:transferring_in) { [transferring_in_participant] }
      let(:transferring_out) { [transferring_out_participant] }
      let(:fip_no_qts_ects) { [ect_no_qts] }
      let(:fip_no_qts_mentors) { [mentor_no_qts] }

      before do
        FeatureFlag.activate(:eligibility_notifications)
        ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
        ineligible_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
        ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
        ero_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
        details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
        details_being_checked_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
        ect_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
        mentor_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
      end

      context "change_of_circumstances feature flag inactive" do
        before do
          FeatureFlag.deactivate(:change_of_circumstances)

          @ect_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::ECT")
          @mentor_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::Mentor")
        end

        it "returns eligible participants in eligible category" do
          expect(@ect_categories.eligible).to match_array(fip_eligible_ects)
          expect(@mentor_categories.eligible).to match_array(fip_eligible_mentors)
        end

        it "returns ineligible participants in ineligible category" do
          expect(@ect_categories.ineligible).to match_array(fip_ineligible_ects)
          expect(@mentor_categories.ineligible).to match_array(fip_ineligible_mentors)
        end

        it "returns contacted_for_info participants in contacted_for_info category" do
          expect(@ect_categories.contacted_for_info).to match_array(fip_contacted_for_info_ects)
          expect(@mentor_categories.contacted_for_info).to match_array(fip_contacted_for_info_mentors)
        end

        it "returns details_being_checked participants in details_being_checked category" do
          expect(@ect_categories.details_being_checked).to match_array(fip_details_being_checked_ects)
          expect(@mentor_categories.details_being_checked).to match_array(fip_details_being_checked_mentors)
        end

        it "returns no_qts_participants in no_qts_participants category" do
          expect(@ect_categories.no_qts_participants).to match_array(fip_no_qts_ects)
          expect(@mentor_categories.no_qts_participants).to match_array(fip_no_qts_mentors)
        end

        it "returns withdrawn participants in withdrawn category" do
          expect(@ect_categories.withdrawn).to match_array(withdrawn_ects)
        end
      end

      context "change_of_circumstances feature flag active" do
        before do
          FeatureFlag.activate(:change_of_circumstances)
          ParticipantProfile::ECF.all.each do |participant_profile|
            Induction::Enrol.call(induction_programme:, participant_profile:)
          end

          transferring_in_participant.induction_records.first.update!(start_date: 2.weeks.from_now)
          transferring_out_participant.induction_records.first.leaving!(6.weeks.from_now)

          @ect_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::ECT")
          @mentor_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::Mentor")
        end

        it "returns eligible participants in eligible category" do
          expect(@ect_categories.eligible).to match_array(fip_eligible_ects)
          expect(@mentor_categories.eligible).to match_array(fip_eligible_mentors)
        end

        it "returns ineligible participants in ineligible category" do
          expect(@ect_categories.ineligible).to match_array(fip_ineligible_ects)
          expect(@mentor_categories.ineligible).to match_array(fip_ineligible_mentors)
        end

        it "returns contacted_for_info participants in contacted_for_info category" do
          expect(@ect_categories.contacted_for_info).to match_array(fip_contacted_for_info_ects)
          expect(@mentor_categories.contacted_for_info).to match_array(fip_contacted_for_info_mentors)
        end

        it "returns details_being_checked participants in details_being_checked category" do
          expect(@ect_categories.details_being_checked).to match_array(fip_details_being_checked_ects)
          expect(@mentor_categories.details_being_checked).to match_array(fip_details_being_checked_mentors)
        end

        it "returns no_qts_participants in no_qts_participants category" do
          expect(@ect_categories.no_qts_participants).to match_array(fip_no_qts_ects)
          expect(@mentor_categories.no_qts_participants).to match_array(fip_no_qts_mentors)
        end

        it "returns withdrawn participants in withdrawn category" do
          expect(@ect_categories.withdrawn).to match_array(withdrawn_ects)
        end
      end
    end

    context "FIP cohorts with inactive eligibility_notifications feature flag" do
      let(:school_cohort) { create(:school_cohort, :fip) }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      let(:fip_eligible_ects) { [] }
      let(:fip_eligible_mentors) { [] }
      let(:fip_ineligible_ects) { [] }
      let(:fip_ineligible_mentors) { [] }
      let(:fip_contacted_for_info_ects) { [contacted_for_info_ect] }
      let(:fip_contacted_for_info_mentors) { [contacted_for_info_mentor] }
      let(:fip_details_being_checked_ects) { [eligible_ect, ineligible_ect, ero_ect, details_being_checked_ect, ect_no_qts] }
      let(:fip_details_being_checked_mentors) { [eligible_mentor, ineligible_mentor, ero_mentor, details_being_checked_mentor, primary_mentor, secondary_mentor, mentor_no_qts] }
      let(:fip_no_qts_ects) { [] }
      let(:fip_no_qts_mentors) { [] }
      let(:withdrawn_ects) { [withdrawn_ect] }

      before do
        FeatureFlag.deactivate(:eligibility_notifications)

        ineligible_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
        ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
        ero_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
        ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
        details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
        details_being_checked_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
        ect_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
        mentor_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")

        @ect_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::ECT")
        @mentor_categories = service.call(school_cohort, induction_coordinator.user, "ParticipantProfile::Mentor")
      end

      it "does not return participants in eligible category" do
        expect(@ect_categories.eligible).to match_array(fip_eligible_ects)
        expect(@mentor_categories.eligible).to match_array(fip_eligible_mentors)
      end

      it "does not return participants in ineligible category" do
        expect(@ect_categories.ineligible).to match_array(fip_ineligible_ects)
        expect(@mentor_categories.ineligible).to match_array(fip_ineligible_mentors)
      end

      it "returns contacted_for_info participants in contacted_for_info category" do
        expect(@ect_categories.contacted_for_info).to match_array(fip_contacted_for_info_ects)
        expect(@mentor_categories.contacted_for_info).to match_array(fip_contacted_for_info_mentors)
      end

      it "returns details_being_checked, ineligible and eligible participants in details_being_checked category" do
        expect(@ect_categories.details_being_checked).to match_array(fip_details_being_checked_ects)
        expect(@mentor_categories.details_being_checked).to match_array(fip_details_being_checked_mentors)
      end

      it "returns no_qts_participant, ineligible and eligible participants in no_qts_participants category" do
        expect(@ect_categories.no_qts_participants).to match_array(fip_no_qts_ects)
        expect(@mentor_categories.no_qts_participants).to match_array(fip_no_qts_mentors)
      end

      it "returns details_being_checked, ineligible and eligible participants in details_being_checked category" do
        expect(@ect_categories.withdrawn).to match_array(withdrawn_ects)
      end
    end
  end
end
