# frozen_string_literal: true

require "rails_helper"

RSpec.describe CocSetParticipantCategories, with_feature_flags: { change_of_circumstances: "active" } do
  describe "#run" do
    subject(:service) { described_class }

    let(:school) { create(:school) }
    let(:school_cohort) { create(:school_cohort, :cip) }
    let(:cip_programme) { create(:induction_programme, :cip, school_cohort:) }
    let(:fip_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:school_funded_fip_programme) { create(:induction_programme, :school_funded_fip, school_cohort:) }
    # FIP
    let(:fip_eligible_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_eligible_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_ineligible_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_ineligible_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_contacted_for_info_ect) { create(:ect_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort:) }
    let(:fip_contacted_for_info_mentor) { create(:mentor_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort:) }
    let(:fip_ero_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_ero_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_details_being_checked_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_details_being_checked_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_primary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :primary_profile, school_cohort:) }
    let(:fip_secondary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :secondary_profile, school_cohort:) }
    let(:fip_withdrawn_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, training_status: "withdrawn", school_cohort:) }
    let(:fip_transferring_in_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_transferring_out_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_transferred_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_transferred_withdrawn_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_ect_no_qts) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:fip_mentor_no_qts) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    # CIP
    let(:cip_eligible_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_eligible_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_ineligible_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_ineligible_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_contacted_for_info_ect) { create(:ect_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort:) }
    let(:cip_contacted_for_info_mentor) { create(:mentor_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort:) }
    let(:cip_ero_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_ero_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_details_being_checked_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_details_being_checked_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_primary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :primary_profile, school_cohort:) }
    let(:cip_secondary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :secondary_profile, school_cohort:) }
    let(:cip_withdrawn_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, training_status: "withdrawn", school_cohort:) }
    let(:cip_transferring_in_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_transferring_out_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_transferred_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_transferred_withdrawn_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_ect_no_qts) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:cip_mentor_no_qts) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    # School Funded FIP
    let(:school_funded_fip_eligible_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_eligible_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_ineligible_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_ineligible_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_contacted_for_info_ect) { create(:ect_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort:) }
    let(:school_funded_fip_contacted_for_info_mentor) { create(:mentor_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, school_cohort:) }
    let(:school_funded_fip_ero_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_ero_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_details_being_checked_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_details_being_checked_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_primary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :primary_profile, school_cohort:) }
    let(:school_funded_fip_secondary_mentor) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, :secondary_profile, school_cohort:) }
    let(:school_funded_fip_withdrawn_ect) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, training_status: "withdrawn", school_cohort:) }
    let(:school_funded_fip_transferring_in_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_transferring_out_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_transferred_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_transferred_withdrawn_participant) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_ect_no_qts) { create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }
    let(:school_funded_fip_mentor_no_qts) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort:) }

    let(:fip_participants) do
      [
        fip_eligible_ect,
        fip_eligible_mentor,
        fip_ineligible_ect,
        fip_ineligible_mentor,
        fip_contacted_for_info_ect,
        fip_contacted_for_info_mentor,
        fip_ero_ect,
        fip_ero_mentor,
        fip_details_being_checked_ect,
        fip_details_being_checked_mentor,
        fip_primary_mentor,
        fip_secondary_mentor,
        fip_withdrawn_ect,
        fip_transferring_in_participant,
        fip_transferring_out_participant,
        fip_transferred_participant,
        fip_transferred_withdrawn_participant,
        fip_ect_no_qts,
        fip_mentor_no_qts,
      ]
    end

    let(:cip_participants) do
      [
        cip_eligible_ect,
        cip_eligible_mentor,
        cip_ineligible_ect,
        cip_ineligible_mentor,
        cip_contacted_for_info_ect,
        cip_contacted_for_info_mentor,
        cip_ero_ect,
        cip_ero_mentor,
        cip_details_being_checked_ect,
        cip_details_being_checked_mentor,
        cip_primary_mentor,
        cip_secondary_mentor,
        cip_withdrawn_ect,
        cip_transferring_in_participant,
        cip_transferring_out_participant,
        cip_transferred_participant,
        cip_transferred_withdrawn_participant,
        cip_ect_no_qts,
        cip_mentor_no_qts,
      ]
    end

    let(:school_funded_fip_participants) do
      [
        school_funded_fip_eligible_ect,
        school_funded_fip_eligible_mentor,
        school_funded_fip_ineligible_ect,
        school_funded_fip_ineligible_mentor,
        school_funded_fip_contacted_for_info_ect,
        school_funded_fip_contacted_for_info_mentor,
        school_funded_fip_ero_ect,
        school_funded_fip_ero_mentor,
        school_funded_fip_details_being_checked_ect,
        school_funded_fip_details_being_checked_mentor,
        school_funded_fip_primary_mentor,
        school_funded_fip_secondary_mentor,
        school_funded_fip_withdrawn_ect,
        school_funded_fip_transferring_in_participant,
        school_funded_fip_transferring_out_participant,
        school_funded_fip_transferred_participant,
        school_funded_fip_transferred_withdrawn_participant,
        school_funded_fip_ect_no_qts,
        school_funded_fip_mentor_no_qts,
      ]
    end

    context "School with FIP default" do
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      before do
        setup_fip_participants
      end

      # NOTE: all categories under one spec as otherwise very slow
      it "returns induction_records in correct category" do
        # eligible
        expect(@ect_categories.eligible).to match_array([fip_eligible_ect, fip_ero_ect].map(&:current_induction_record))
        expect(@mentor_categories.eligible).to match_array([fip_eligible_mentor, fip_ero_mentor, fip_primary_mentor, fip_secondary_mentor].map(&:current_induction_record))

        # ineligible
        expect(@ect_categories.ineligible).to match_array(fip_ineligible_ect.current_induction_record)
        expect(@mentor_categories.ineligible).to match_array(fip_ineligible_mentor.current_induction_record)

        # contacted_for_info
        expect(@ect_categories.contacted_for_info).to match_array(fip_contacted_for_info_ect.current_induction_record)
        expect(@mentor_categories.contacted_for_info).to match_array(fip_contacted_for_info_mentor.current_induction_record)

        # details_being_checked
        expect(@ect_categories.details_being_checked).to match_array(fip_details_being_checked_ect.current_induction_record)
        expect(@mentor_categories.details_being_checked).to match_array(fip_details_being_checked_mentor.current_induction_record)

        # withdrawn
        expect(@ect_categories.withdrawn).to match_array(fip_withdrawn_ect.current_induction_record)

        # transferring_in
        expect(@ect_categories.transferring_in).to match_array(fip_transferring_in_participant.induction_records.latest)

        # transferring_out
        expect(@ect_categories.transferring_out).to match_array(fip_transferring_out_participant.induction_records.latest)

        # transferred
        expect(@ect_categories.transferred).to match_array([fip_transferred_participant, fip_transferred_withdrawn_participant].map { |profile| profile.induction_records.latest })

        # no_qts
        expect(@ect_categories.no_qts_participants).to match_array(fip_ect_no_qts.current_induction_record)
        expect(@mentor_categories.no_qts_participants).to match_array(fip_mentor_no_qts.current_induction_record)
      end
    end

    context "School with CIP default" do
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      before do
        setup_cip_participants
      end

      # NOTE: all categories under one spec as otherwise very slow
      it "returns participants in correct category" do
        # eligible
        expect(@ect_categories.eligible).to match_array([cip_eligible_ect, cip_ineligible_ect, cip_ero_ect, cip_details_being_checked_ect, cip_ect_no_qts].map(&:current_induction_record))
        expect(@mentor_categories.eligible).to match_array([cip_eligible_mentor, cip_ineligible_mentor, cip_ero_mentor, cip_details_being_checked_mentor, cip_primary_mentor, cip_secondary_mentor, cip_mentor_no_qts].map(&:current_induction_record))

        # ineligible
        expect(@ect_categories.ineligible).to be_empty
        expect(@mentor_categories.ineligible).to be_empty

        # contacted_for_info
        expect(@ect_categories.contacted_for_info).to match_array(cip_contacted_for_info_ect.current_induction_record)
        expect(@mentor_categories.contacted_for_info).to match_array(cip_contacted_for_info_mentor.current_induction_record)

        # details_being_checked
        expect(@ect_categories.details_being_checked).to be_empty
        expect(@mentor_categories.details_being_checked).to be_empty

        # withdrawn
        expect(@ect_categories.withdrawn).to match_array(cip_withdrawn_ect.current_induction_record)

        # transferring_in
        # expect(@ect_categories.transferring_in).to match_array(cip_transferring_in_participant.induction_records.latest)

        # transferring_out
        expect(@ect_categories.transferring_out).to match_array(cip_transferring_out_participant.induction_records.latest)

        # transferred
        expect(@ect_categories.no_qts_participants).to be_empty
        expect(@mentor_categories.no_qts_participants).to be_empty
      end
    end

    context "School with school_funded_fip default" do
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      before do
        setup_school_funded_fip_participants
      end

      # NOTE: all categories under one spec as otherwise very slow
      it "returns induction_records in correct category" do
        # eligible
        expect(@ect_categories.eligible).to match_array([school_funded_fip_eligible_ect, school_funded_fip_ero_ect].map(&:current_induction_record))
        expect(@mentor_categories.eligible).to match_array([school_funded_fip_eligible_mentor, school_funded_fip_ero_mentor, school_funded_fip_primary_mentor, school_funded_fip_secondary_mentor].map(&:current_induction_record))

        # ineligible
        expect(@ect_categories.ineligible).to match_array(school_funded_fip_ineligible_ect.current_induction_record)
        expect(@mentor_categories.ineligible).to match_array(school_funded_fip_ineligible_mentor.current_induction_record)

        # contacted_for_info
        expect(@ect_categories.contacted_for_info).to match_array(school_funded_fip_contacted_for_info_ect.current_induction_record)
        expect(@mentor_categories.contacted_for_info).to match_array(school_funded_fip_contacted_for_info_mentor.current_induction_record)

        # details_being_checked
        expect(@ect_categories.details_being_checked).to match_array(school_funded_fip_details_being_checked_ect.current_induction_record)
        expect(@mentor_categories.details_being_checked).to match_array(school_funded_fip_details_being_checked_mentor.current_induction_record)

        # withdrawn
        expect(@ect_categories.withdrawn).to match_array(school_funded_fip_withdrawn_ect.current_induction_record)

        # transferring_in
        expect(@ect_categories.transferring_in).to match_array(school_funded_fip_transferring_in_participant.induction_records.latest)

        # transferring_out
        expect(@ect_categories.transferring_out).to match_array(school_funded_fip_transferring_out_participant.induction_records.latest)

        # transferred
        expect(@ect_categories.transferred).to match_array([school_funded_fip_transferred_participant, school_funded_fip_transferred_withdrawn_participant].map { |profile| profile.induction_records.latest })

        # no_qts
        expect(@ect_categories.no_qts_participants).to match_array(school_funded_fip_ect_no_qts.current_induction_record)
        expect(@mentor_categories.no_qts_participants).to match_array(school_funded_fip_mentor_no_qts.current_induction_record)
      end
    end

    context "FIP, CIP and school_funded_fip induction programmes" do
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school_cohort.school]) }

      before do
        setup_fip_participants
        setup_cip_participants
        setup_school_funded_fip_participants
      end

      # NOTE: all categories under one spec as otherwise very slow
      it "returns participants in correct category" do
        # eligible
        expect(@ect_categories.eligible).to match_array([fip_eligible_ect, fip_ero_ect, cip_eligible_ect, cip_ineligible_ect, cip_ero_ect, cip_details_being_checked_ect, cip_ect_no_qts, school_funded_fip_eligible_ect, school_funded_fip_ero_ect].map(&:current_induction_record))
        expect(@mentor_categories.eligible).to match_array([fip_eligible_mentor, fip_ero_mentor, fip_primary_mentor, fip_secondary_mentor, cip_eligible_mentor, cip_ineligible_mentor, cip_ero_mentor, cip_details_being_checked_mentor, cip_primary_mentor, cip_secondary_mentor, cip_mentor_no_qts, school_funded_fip_eligible_mentor, school_funded_fip_ero_mentor, school_funded_fip_primary_mentor, school_funded_fip_secondary_mentor].map(&:current_induction_record))

        # ineligible
        expect(@ect_categories.ineligible).to match_array([fip_ineligible_ect, school_funded_fip_ineligible_ect].map(&:current_induction_record))
        expect(@mentor_categories.ineligible).to match_array([fip_ineligible_mentor, school_funded_fip_ineligible_mentor].map(&:current_induction_record))

        # contacted_for_info
        expect(@ect_categories.contacted_for_info).to match_array([fip_contacted_for_info_ect, cip_contacted_for_info_ect, school_funded_fip_contacted_for_info_ect].map(&:current_induction_record))
        expect(@mentor_categories.contacted_for_info).to match_array([fip_contacted_for_info_mentor, cip_contacted_for_info_mentor, school_funded_fip_contacted_for_info_mentor].map(&:current_induction_record))

        # details_being_checked
        expect(@ect_categories.details_being_checked).to match_array([fip_details_being_checked_ect, school_funded_fip_details_being_checked_ect].map(&:current_induction_record))
        expect(@mentor_categories.details_being_checked).to match_array([fip_details_being_checked_mentor, school_funded_fip_details_being_checked_mentor].map(&:current_induction_record))

        # withdrawn
        expect(@ect_categories.withdrawn).to match_array([fip_withdrawn_ect, cip_withdrawn_ect, school_funded_fip_withdrawn_ect].map(&:current_induction_record))

        # transferring_in
        # expect(@ect_categories.transferring_in).to match_array([fip_transferring_in_participant, cip_transferring_in_participant].map { |profile| profile.induction_records.latest })

        # transferring_out
        expect(@ect_categories.transferring_out).to match_array([fip_transferring_out_participant, cip_transferring_out_participant, school_funded_fip_transferring_out_participant].map { |profile| profile.induction_records.latest })

        # transferred
        expect(@ect_categories.transferred).to match_array([fip_transferred_participant, fip_transferred_withdrawn_participant, cip_transferred_participant, cip_transferred_withdrawn_participant, school_funded_fip_transferred_participant, school_funded_fip_transferred_withdrawn_participant].map { |profile| profile.induction_records.latest })

        # no_qts
        expect(@ect_categories.no_qts_participants).to match_array([fip_ect_no_qts, school_funded_fip_ect_no_qts].map(&:current_induction_record))
        expect(@mentor_categories.no_qts_participants).to match_array([fip_mentor_no_qts, school_funded_fip_mentor_no_qts].map(&:current_induction_record))
      end
    end

    context "SIT for multiple schools" do
      let(:school_cohorts) { create_list(:school_cohort, 3, :cip) }
      let(:school_cohort) { school_cohorts.first }
      let(:induction_coordinator) { create(:induction_coordinator_profile, schools: school_cohorts.map(&:school)) }

      before do
        cip_participants.each do |profile|
          Induction::Enrol.call(participant_profile: profile, induction_programme: cip_programme)
        end
        cip_transferring_in_participant.induction_records.first.update!(start_date: 2.months.from_now)
        cip_transferring_out_participant.induction_records.first.update!(school_transfer: true, induction_status: :leaving, end_date: 1.month.from_now)
        cip_transferred_participant.induction_records.first.leaving!(1.month.ago)
        cip_transferred_withdrawn_participant.induction_records.first.training_status_withdrawn!
        cip_withdrawn_ect.induction_records.first.training_status_withdrawn!

        @ects = []
        school_cohorts.each do |a_school_cohort|
          programme = create(:induction_programme, :cip, school_cohort: a_school_cohort)
          ect = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: a_school_cohort)
          a_school_cohort.update!(default_induction_programme: programme)
          Induction::Enrol.call(participant_profile: ect, induction_programme: programme)
          @ects << ect
        end
      end

      it "only returns ECTs for the selected school cohort" do
        ect_categories = service.call(school_cohort, induction_coordinator.user, ParticipantProfile::ECT)
        expect(ect_categories.eligible).to match_array([cip_eligible_ect, cip_ineligible_ect, cip_ero_ect, cip_details_being_checked_ect, @ects.first, fip_transferring_in_participant, cip_transferring_in_participant, cip_ect_no_qts].map(&:current_induction_record).compact)
      end

      it "only returns mentors for the selected school cohort" do
        mentor_categories = service.call(school_cohort, induction_coordinator.user, ParticipantProfile::Mentor)

        expect(mentor_categories.eligible).to match_array([cip_eligible_mentor, cip_ineligible_mentor, cip_ero_mentor, cip_details_being_checked_mentor, cip_primary_mentor, cip_secondary_mentor, cip_mentor_no_qts].map(&:current_induction_record))
      end
    end
  end

  def setup_fip_participants
    school_cohort.update!(induction_programme_choice: :full_induction_programme, default_induction_programme: fip_programme)
    fip_participants.each do |profile|
      Induction::Enrol.call(participant_profile: profile, induction_programme: fip_programme)
    end
    fip_transferring_in_participant.induction_records.first.update!(start_date: 2.months.from_now, school_transfer: true)
    fip_transferring_out_participant.induction_records.first.update!(school_transfer: true, induction_status: :leaving, end_date: 1.month.from_now)
    fip_transferred_participant.induction_records.first.leaving!(1.month.ago)
    fip_transferred_withdrawn_participant.induction_records.first.leaving!(1.month.ago)
    fip_transferred_withdrawn_participant.induction_records.first.training_status_withdrawn!
    fip_withdrawn_ect.induction_records.first.training_status_withdrawn!

    fip_ineligible_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    fip_ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    fip_ero_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
    fip_ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
    fip_details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
    fip_details_being_checked_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
    fip_ect_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
    fip_mentor_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")

    [fip_primary_mentor, fip_secondary_mentor].each do |profile|
      profile.ecf_participant_eligibility.determine_status
      profile.ecf_participant_eligibility.save!
    end

    @ect_categories = service.call(school_cohort, induction_coordinator.user, ParticipantProfile::ECT)
    @mentor_categories = service.call(school_cohort, induction_coordinator.user, ParticipantProfile::Mentor)
  end

  def setup_cip_participants
    school_cohort.update!(default_induction_programme: cip_programme)
    cip_participants.each do |profile|
      Induction::Enrol.call(participant_profile: profile, induction_programme: cip_programme)
    end
    cip_transferring_in_participant.induction_records.first.update!(start_date: 2.months.from_now, school_transfer: true)
    cip_transferring_out_participant.induction_records.first.update!(school_transfer: true, induction_status: :leaving, end_date: 1.month.from_now)
    cip_transferred_participant.induction_records.first.leaving!(1.month.ago)
    cip_transferred_withdrawn_participant.induction_records.first.leaving!(1.month.ago)
    cip_transferred_withdrawn_participant.induction_records.first.training_status_withdrawn!
    cip_withdrawn_ect.induction_records.first.training_status_withdrawn!

    cip_ineligible_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    cip_ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    cip_ero_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
    cip_ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
    cip_details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
    cip_details_being_checked_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
    cip_ect_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
    cip_mentor_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")

    [cip_primary_mentor, cip_secondary_mentor].each do |profile|
      profile.ecf_participant_eligibility.determine_status
      profile.ecf_participant_eligibility.save!
    end

    @ect_categories = service.call(school_cohort, induction_coordinator.user, ParticipantProfile::ECT)
    @mentor_categories = service.call(school_cohort, induction_coordinator.user, ParticipantProfile::Mentor)
  end

  def setup_school_funded_fip_participants
    school_cohort.update!(induction_programme_choice: :full_induction_programme, default_induction_programme: school_funded_fip_programme)
    school_funded_fip_participants.each do |profile|
      Induction::Enrol.call(participant_profile: profile, induction_programme: school_funded_fip_programme)
    end
    school_funded_fip_transferring_in_participant.induction_records.first.update!(start_date: 2.months.from_now, school_transfer: true)
    school_funded_fip_transferring_out_participant.induction_records.first.update!(school_transfer: true, induction_status: :leaving, end_date: 1.month.from_now)
    school_funded_fip_transferred_participant.induction_records.first.leaving!(1.month.ago)
    school_funded_fip_transferred_withdrawn_participant.induction_records.first.leaving!(1.month.ago)
    school_funded_fip_transferred_withdrawn_participant.induction_records.first.training_status_withdrawn!
    school_funded_fip_withdrawn_ect.induction_records.first.training_status_withdrawn!

    school_funded_fip_ineligible_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    school_funded_fip_ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    school_funded_fip_ero_ect.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
    school_funded_fip_ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
    school_funded_fip_details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
    school_funded_fip_details_being_checked_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
    school_funded_fip_ect_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
    school_funded_fip_mentor_no_qts.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")

    [school_funded_fip_primary_mentor, school_funded_fip_secondary_mentor].each do |profile|
      profile.ecf_participant_eligibility.determine_status
      profile.ecf_participant_eligibility.save!
    end

    @ect_categories = service.call(school_cohort, induction_coordinator.user, ParticipantProfile::ECT)
    @mentor_categories = service.call(school_cohort, induction_coordinator.user, ParticipantProfile::Mentor)
  end
end
