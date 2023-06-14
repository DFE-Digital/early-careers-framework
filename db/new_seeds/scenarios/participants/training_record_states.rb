# frozen_string_literal: true

require "active_support/testing/time_helpers"

module NewSeeds
  module Scenarios
    module Participants
      # noinspection RubyInstanceMethodNamingConvention, RubyTooManyMethodsInspection, RubyInstanceVariableNamingConvention, RubyTooManyInstanceVariablesInspection
      class TrainingRecordStates
        include ActiveSupport::Testing::TimeHelpers

        def cohort
          @cohort ||= Cohort.current || FactoryBot.create(:cohort, :current)
        end

        def previous_cohort
          @previous_cohort ||= Cohort.previous || FactoryBot.create(:cohort, start_year: cohort.start_year - 1)
        end

        def fip_school
          @fip_school ||= NewSeeds::Scenarios::Schools::School
            .new(name: "FIP School for Training Record States")
            .build
            .with_an_induction_tutor(full_name: "FIP School for Training Record States SIT", email: "fip-training-states@example.com")
            .chosen_fip_and_partnered_in(cohort:)
        end

        def fip_school_no_partnership
          @fip_school_no_partnership ||= NewSeeds::Scenarios::Schools::School
                                           .new(name: "FIP School with no Partnership for Training Record States")
                                           .build
                                           .with_an_induction_tutor(full_name: "FIP School with no Partnership for Training Record States SIT", email: "fip-no-partner-training-states@example.com")
                                           .chosen_fip_but_not_partnered(cohort:)
        end

        def fip_school_with_previous_fip_cohort
          @fip_school_with_previous_fip_cohort ||= NewSeeds::Scenarios::Schools::School
                                                     .new(name: "FIP School with previous FIP induction programme cohort")
                                                     .build
                                                     .with_an_induction_tutor(full_name: "FIP School with previous FIP induction programme cohort SIT", email: "fip-previous-fip-programme-cohort@example.com")
                                                     .chosen_fip_and_partnered_in(cohort: previous_cohort)
                                                     .chosen_fip_and_partnered_in(cohort:)
        end

        def cip_school
          @cip_school ||= NewSeeds::Scenarios::Schools::School
            .new(name: "CIP School for Training Record States")
            .build
            .with_an_induction_tutor(full_name: "CIP School for Training Record States SIT", email: "cip-training-states@example.com")
            .chosen_cip_with_materials_in(cohort:)
        end

        # FIP ECTs

        def ect_on_fip_no_validation
          school_cohort = fip_school.school_cohort

          @ect_on_fip_no_validation ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: no validation")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_details_request_submitted
          school_cohort = fip_school.school_cohort

          @ect_on_fip_details_request_submitted ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: details request submitted")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_request_for_details_email
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_details_request_failed
          school_cohort = fip_school.school_cohort

          @ect_on_fip_details_request_failed ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: details request failed")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
            .with_request_for_details_email(status: "temporary-failure")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_details_request_delivered
          school_cohort = fip_school.school_cohort

          @ect_on_fip_details_request_delivered ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: details request delivered")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
            .with_request_for_details_email(status: "delivered")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_validation_api_failure
          school_cohort = fip_school.school_cohort

          @ect_on_fip_validation_api_failure ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: Teacher Qualifications API failure")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_validation_data(api_failure: true)
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_no_tra_record
          school_cohort = fip_school.school_cohort

          @ect_on_fip_no_tra_record ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: No TRA record found")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_validation_data
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_sparsity_uplift
          school_cohort = fip_school.school_cohort

          @ect_on_fip_sparsity_uplift ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: with sparsity uplift")
            .build(sparsity_uplift: true)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_pupil_premium_uplift
          school_cohort = fip_school.school_cohort

          @ect_on_fip_pupil_premium_uplift ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: with pupil premium uplift")
            .build(pupil_premium_uplift: true)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_no_uplift
          school_cohort = fip_school.school_cohort

          @ect_on_fip_no_uplift ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: with no uplift")
            .build(sparsity_uplift: false, pupil_premium_uplift: false)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_manual_check_active_flags
          school_cohort = fip_school.school_cohort

          @ect_on_fip_manual_check_active_flags ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: requires manual check of active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_manual_check_different_trn
          school_cohort = fip_school.school_cohort

          @ect_on_fip_manual_check_different_trn ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: requires manual check due to different TRN")
            .build
            .with_validation_data
            .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_manual_check_no_induction
          school_cohort = fip_school.school_cohort

          @ect_on_fip_manual_check_no_induction ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: with no induction start date recorded")
            .build(induction_start_date: nil)
            .with_validation_data
            .with_eligibility(no_induction: true, status: "manual_check", reason: "no_induction")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_manual_check_no_qts
          school_cohort = fip_school.school_cohort

          @ect_on_fip_manual_check_no_qts ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: with no QTS recorded")
            .build
            .with_validation_data
            .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_ineligible_active_flags
          school_cohort = fip_school.school_cohort

          @ect_on_fip_ineligible_active_flags ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: ineligible due to active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_eligible_active_flags
          school_cohort = fip_school.school_cohort

          @ect_on_fip_eligible_active_flags ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: eligible despite active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "eligible", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_ineligible_duplicate_profile
          school_cohort = fip_school.school_cohort

          @ect_on_fip_ineligible_duplicate_profile ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: ineligible due to duplicate profile")
            .build
            .with_validation_data
            .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_ineligible_exempt_from_induction
          school_cohort = fip_school.school_cohort

          @ect_on_fip_ineligible_exempt_from_induction ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: exempt from statutory induction")
            .build
            .with_validation_data
            .with_eligibility(exempt_from_induction: true, status: "ineligible", reason: "exempt_from_induction")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_ineligible_previous_induction
          school_cohort = fip_school.school_cohort

          @ect_on_fip_ineligible_previous_induction ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: ineligible due to previous induction records")
            .build
            .with_validation_data
            .with_eligibility(previous_induction: true, status: "ineligible", reason: "previous_induction")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_no_eligibility_checks
          school_cohort = fip_school.school_cohort

          @ect_on_fip_no_eligibility_checks ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: no eligibility checks done")
            .build
            .with_validation_data
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_eligible
          school_cohort = fip_school.school_cohort

          @ect_on_fip_eligible ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: made eligible by DfE")
            .build(sparsity_uplift: true, pupil_premium_uplift: true)
            .with_validation_data
            .with_eligibility(status: "eligible")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_no_partnership
          school_cohort = fip_school_no_partnership.school_cohort

          @ect_on_fip_no_partnership ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: no lead provider")
            .build(sparsity_uplift: true, pupil_premium_uplift: true)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip
          school_cohort = fip_school.school_cohort

          @ect_on_fip ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP")
            .build(sparsity_uplift: true, pupil_premium_uplift: true)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_withdrawn
          school_cohort = fip_school.school_cohort

          @ect_on_fip_withdrawn ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: withdrawn by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "withdrawn")
        end

        def ect_on_fip_enrolled_after_withdraw
          school_cohort = fip_school.school_cohort

          @ect_on_fip_enrolled_after_withdraw ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: enrolled after being withdrawn")
            .build(status: "withdrawn")
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_fip_withdrawn_no_induction_record
          school_cohort = fip_school.school_cohort

          @ect_on_fip_withdrawn_no_induction_record ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: withdrawn by lead provider before induction records")
            .build(induction_start_date: nil, training_status: "withdrawn")
            .with_validation_data
            .with_eligibility
        end

        def ect_on_fip_deferred
          school_cohort = fip_school.school_cohort

          @ect_on_fip_deferred ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: deferred by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "deferred")
        end

        def ect_on_fip_withdrawn_from_programme
          school_cohort = fip_school.school_cohort

          @ect_on_fip_withdrawn_from_programme ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: withdrawn from programme")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "withdrawn")
        end

        def ect_on_fip_completed
          school_cohort = fip_school.school_cohort

          @ect_on_fip_completed ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: withdrawn by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "completed")
        end

        def ect_on_fip_after_cohort_transfer
          current_school_cohort = fip_school_with_previous_fip_cohort.school_cohorts[Cohort.current.start_year]
          previous_school_cohort = fip_school_with_previous_fip_cohort.school_cohorts[Cohort.previous.start_year]

          @ect_on_fip_after_cohort_transfer ||= travel_to(2.days.ago) do
            NewSeeds::Scenarios::Participants::Ects::Ect
                                      .new(school_cohort: current_school_cohort, full_name: "ECT on FIP: after cohort transfer")
                                      .build
                                      .with_validation_data
                                      .with_eligibility
          end

          @ect_on_fip_after_cohort_transfer
            .with_induction_record(induction_programme: current_school_cohort.default_induction_programme, induction_status: "changed", start_date: 1.day.ago, end_date: Time.zone.now)
            .with_induction_record(induction_programme: previous_school_cohort.default_induction_programme, induction_status: "active", start_date: Time.zone.now)
        end

        def ect_on_fip_after_mentor_change
          return @ect_on_fip_after_cohort_transfer if @ect_on_fip_after_cohort_transfer.present?

          school_cohort = fip_school.school_cohort
          induction_programme = school_cohort.default_induction_programme

          mentor_profile = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
                             .new(school_cohort:)
                             .build
                             .with_validation_data
                             .with_eligibility
                             .with_induction_record(induction_programme: school_cohort.default_induction_programme)
                             .participant_profile

          @ect_on_fip_after_cohort_transfer = travel_to(2.days.ago) do
            NewSeeds::Scenarios::Participants::Ects::Ect
              .new(school_cohort:, full_name: "ECT on FIP: after mentor change")
              .build
              .with_validation_data
              .with_eligibility
          end

          @ect_on_fip_after_cohort_transfer
            .with_induction_record(induction_programme:, mentor_profile: nil, induction_status: "changed", start_date: 1.day.ago, end_date: Time.zone.now)
            .with_induction_record(induction_programme:, mentor_profile:, induction_status: "active", start_date: Time.zone.now)
        end

        # FIP transfer scenarios

        def ect_on_fip_leaving
          school_cohort = fip_school.school_cohort

          transfer_date = 1.month.from_now

          @ect_on_fip_leaving ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: leaving a FIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
        end

        def ect_on_fip_left
          school_cohort = fip_school.school_cohort

          transfer_date = 1.month.ago

          @ect_on_fip_left ||= travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Ects::Ect
              .new(school_cohort:, full_name: "ECT on FIP: left a FIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
          end
        end

        def ect_on_fip_transferring
          school_cohort = fip_school.school_cohort
          school_cohort_2 = cip_school.school_cohort

          transfer_date = 1.month.from_now

          @ect_on_fip_transferring ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: transferring from a FIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
            .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        end

        def ect_on_fip_transferred
          school_cohort = fip_school.school_cohort
          school_cohort_2 = cip_school.school_cohort

          transfer_date = 1.month.ago

          @ect_on_fip_transferred ||= travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Ects::Ect
              .new(school_cohort:, full_name: "ECT on FIP: transferred from a FIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
              .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
          end
        end

        def ect_on_fip_joining
          school_cohort = cip_school.school_cohort
          school_cohort_2 = fip_school.school_cohort

          transfer_date = 1.month.from_now

          @ect_on_fip_joining ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: joining a FIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
            .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        end

        def ect_on_fip_joined
          school_cohort = cip_school.school_cohort
          school_cohort_2 = fip_school.school_cohort

          transfer_date = 1.month.ago

          @ect_on_fip_joined ||= travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Ects::Ect
              .new(school_cohort:, full_name: "ECT on FIP: joined a FIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
              .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
          end
        end

        # CIP ECTs

        def ect_on_cip_no_validation
          school_cohort = cip_school.school_cohort

          @ect_on_cip_no_validation ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: no validation")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_details_request_submitted
          school_cohort = cip_school.school_cohort

          @ect_on_cip_details_request_submitted ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: details request submitted")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_request_for_details_email
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_details_request_failed
          school_cohort = cip_school.school_cohort

          @ect_on_cip_details_request_failed ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: details request failed")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
            .with_request_for_details_email(status: "temporary-failure")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_details_request_delivered
          school_cohort = cip_school.school_cohort

          @ect_on_cip_details_request_delivered ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: details request delivered")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
            .with_request_for_details_email(status: "delivered")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_validation_api_failure
          school_cohort = cip_school.school_cohort

          @ect_on_cip_validation_api_failure ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: Teacher Qualifications API failure")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_validation_data(api_failure: true)
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_no_tra_record
          school_cohort = cip_school.school_cohort

          @ect_on_cip_no_tra_record ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: No TRA record found")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_validation_data
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_no_uplift
          school_cohort = cip_school.school_cohort

          @ect_on_cip_no_uplift ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: with no uplift")
            .build(sparsity_uplift: false, pupil_premium_uplift: false)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_manual_check_active_flags
          school_cohort = cip_school.school_cohort

          @ect_on_cip_manual_check_active_flags ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: requires manual check of active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_manual_check_different_trn
          school_cohort = cip_school.school_cohort

          @ect_on_cip_manual_check_different_trn ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: requires manual check due to different TRN")
            .build
            .with_validation_data
            .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_manual_check_no_induction
          school_cohort = cip_school.school_cohort

          @ect_on_cip_manual_check_no_induction ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: with no induction start date recorded")
            .build(induction_start_date: nil)
            .with_validation_data
            .with_eligibility(no_induction: true, status: "manual_check", reason: "no_induction")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_manual_check_no_qts
          school_cohort = cip_school.school_cohort

          @ect_on_cip_manual_check_no_qts ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: with no QTS recorded")
            .build
            .with_validation_data
            .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_ineligible_active_flags
          school_cohort = cip_school.school_cohort

          @ect_on_cip_ineligible_active_flags ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: ineligible due to active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_eligible_active_flags
          school_cohort = cip_school.school_cohort

          @ect_on_cip_eligible_active_flags ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: eligible despite active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "eligible", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_ineligible_duplicate_profile
          school_cohort = cip_school.school_cohort

          @ect_on_cip_ineligible_duplicate_profile ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: ineligible due to duplicate profile")
            .build
            .with_validation_data
            .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_ineligible_exempt_from_induction
          school_cohort = cip_school.school_cohort

          @ect_on_cip_ineligible_exempt_from_induction ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: exempt from statutory induction")
            .build
            .with_validation_data
            .with_eligibility(exempt_from_induction: true, status: "ineligible", reason: "exempt_from_induction")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_ineligible_previous_induction
          school_cohort = cip_school.school_cohort

          @ect_on_cip_ineligible_previous_induction ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: ineligible due to previous induction records")
            .build
            .with_validation_data
            .with_eligibility(previous_induction: true, status: "ineligible", reason: "previous_induction")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_no_eligibility_checks
          school_cohort = cip_school.school_cohort

          @ect_on_cip_no_eligibility_checks ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: no eligibility checks done")
            .build
            .with_validation_data
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_eligible
          school_cohort = cip_school.school_cohort

          @ect_on_cip_eligible ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: made eligible by DfE")
            .build
            .with_validation_data
            .with_eligibility(status: "eligible")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip
          school_cohort = cip_school.school_cohort

          @ect_on_cip ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_withdrawn
          school_cohort = cip_school.school_cohort

          @ect_on_cip_withdrawn ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on FIP: withdrawn by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "withdrawn")
        end

        def ect_on_cip_enrolled_after_withdraw
          school_cohort = cip_school.school_cohort

          @ect_on_cip_enrolled_after_withdraw ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: enrolled after being withdrawn")
            .build(status: "withdrawn")
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def ect_on_cip_withdrawn_no_induction_record
          school_cohort = fip_school.school_cohort

          @ect_on_cip_withdrawn_no_induction_record ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: withdrawn by lead provider before induction records")
            .build(induction_start_date: nil, training_status: "withdrawn")
            .with_validation_data
            .with_eligibility
        end

        def ect_on_cip_deferred
          school_cohort = cip_school.school_cohort

          @ect_on_cip_deferred ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: deferred by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "deferred")
        end

        def ect_on_cip_withdrawn_from_programme
          school_cohort = cip_school.school_cohort

          @ect_on_cip_withdrawn_from_programme ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: withdrawn from programme")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "withdrawn")
        end

        def ect_on_cip_completed
          school_cohort = cip_school.school_cohort

          @ect_on_cip_completed ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: withdrawn by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "completed")
        end

        # CIP transfer scenarios

        def ect_on_cip_leaving
          school_cohort = cip_school.school_cohort

          transfer_date = 1.month.from_now

          @ect_on_cip_leaving ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: leaving a CIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
        end

        def ect_on_cip_left
          school_cohort = cip_school.school_cohort

          transfer_date = 1.month.ago

          @ect_on_cip_left ||= travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Ects::Ect
              .new(school_cohort:, full_name: "ECT on CIP: left a CIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
          end
        end

        def ect_on_cip_transferring
          school_cohort = cip_school.school_cohort
          school_cohort_2 = fip_school.school_cohort

          transfer_date = 1.month.from_now

          @ect_on_cip_transferring ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: transferring from a CIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
            .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        end

        def ect_on_cip_transferred
          school_cohort = cip_school.school_cohort
          school_cohort_2 = fip_school.school_cohort

          transfer_date = 1.month.ago

          @ect_on_cip_transferred ||= travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Ects::Ect
              .new(school_cohort:, full_name: "ECT on CIP: transferred from a CIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
              .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
          end
        end

        def ect_on_cip_joining
          school_cohort = fip_school.school_cohort
          school_cohort_2 = cip_school.school_cohort

          transfer_date = 1.month.from_now

          @ect_on_cip_joining ||= NewSeeds::Scenarios::Participants::Ects::Ect
            .new(school_cohort:, full_name: "ECT on CIP: joining a CIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
            .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        end

        def ect_on_cip_joined
          school_cohort = fip_school.school_cohort
          school_cohort_2 = cip_school.school_cohort

          transfer_date = 1.month.ago

          @ect_on_cip_joined ||= travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Ects::Ect
              .new(school_cohort:, full_name: "ECT on CIP: joined a CIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
              .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
          end
        end

        # mentor of FIP

        def mentor_on_fip_no_validation
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_no_validation ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: no validation")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_details_request_submitted
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_details_request_submitted ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: details request submitted")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_request_for_details_email
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_details_request_failed
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_details_request_failed ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: details request failed")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
            .with_request_for_details_email(status: "temporary-failure")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_details_request_delivered
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_details_request_delivered ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: details request delivered")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
            .with_request_for_details_email(status: "delivered")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_validation_api_failure
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_validation_api_failure ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: Teacher Qualifications API failure")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_validation_data(api_failure: true)
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_no_tra_record
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_no_tra_record ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: No TRA record found")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_validation_data
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_manual_check_active_flags
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_manual_check_active_flags ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: requires manual check of active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_manual_check_different_trn
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_manual_check_different_trn ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: requires manual check due to different TRN")
            .build
            .with_validation_data
            .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_manual_check_no_qts
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_manual_check_no_qts ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: with no QTS recorded")
            .build
            .with_validation_data
            .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_eligible_no_qts
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_eligible_no_qts ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: without QTS")
            .build(sparsity_uplift: true)
            .with_validation_data
            .with_eligibility(no_qts: true, status: "eligible", reason: "no_qts")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_ineligible_active_flags
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_ineligible_active_flags ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: ineligible due to active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_eligible_active_flags
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_eligible_active_flags ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: eligible despite active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "eligible", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_ineligible_duplicate_profile
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_ineligible_duplicate_profile ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: ineligible due to duplicate profile")
            .build
            .with_validation_data
            .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_ero_on_fip
          school_cohort = fip_school.school_cohort

          @mentor_ero_on_fip ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "ERO Mentor on FIP")
            .build
            .with_validation_data
            .with_eligibility(previous_participation: true, status: "ineligible", reason: "previous_participation")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_ero_on_fip_eligible
          school_cohort = fip_school.school_cohort

          @mentor_ero_on_fip_eligible ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "ERO Mentor on FIP: made eligible by DfE")
            .build
            .with_validation_data
            .with_eligibility(previous_participation: true, status: "eligible", reason: "previous_participation")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_no_eligibility_checks
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_no_eligibility_checks ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: no eligibility checks done")
            .build
            .with_validation_data
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_eligible
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_eligible ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: made eligible by DfE")
            .build(sparsity_uplift: true, pupil_premium_uplift: true)
            .with_validation_data
            .with_eligibility(status: "eligible")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_profile_duplicity_primary
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_profile_duplicity_primary ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: Primary duplicate profile")
            .build(profile_duplicity: :primary)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_profile_duplicity_secondary
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_profile_duplicity_secondary ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: Secondary duplicate profile")
            .build(profile_duplicity: :secondary)
            .with_validation_data
            .with_eligibility(status: "ineligible", reason: "duplicate_profile")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_no_partnership
          school_cohort = fip_school_no_partnership.school_cohort

          @mentor_on_fip_no_partnership ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: no lead provider")
            .build(sparsity_uplift: true, pupil_premium_uplift: true)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip
          school_cohort = fip_school.school_cohort

          @mentor_on_fip ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP")
            .build(sparsity_uplift: true, pupil_premium_uplift: true)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_with_no_mentees
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_with_no_mentees ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
                                               .new(school_cohort:, full_name: "Mentor on FIP: no mentees")
                                               .build
                                               .with_validation_data
                                               .with_eligibility
                                               .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_no_longer_mentoring
          school_cohort = fip_school.school_cohort
          induction_programme = school_cohort.default_induction_programme

          @mentor_on_fip_no_longer_mentoring ||= travel_to(2.days.ago) do
            builder = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
                        .new(school_cohort:)
                        .build
                        .with_validation_data
                        .with_eligibility
                        .with_induction_record(induction_programme: school_cohort.default_induction_programme)

            NewSeeds::Scenarios::Participants::Ects::Ect
              .new(school_cohort:, full_name: "ECT on FIP: after mentor change")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme:, mentor_profile: builder.participant_profile, induction_status: "changed", start_date: 1.day.ago, end_date: Time.zone.now)
              .with_induction_record(induction_programme:, mentor_profile: nil, induction_status: "active", start_date: Time.zone.now)

            builder
          end
        end

        def mentor_on_fip_withdrawn_mentee
          school_cohort = fip_school.school_cohort
          induction_programme = school_cohort.default_induction_programme

          @mentor_on_fip_withdrawn_mentee ||= travel_to(2.days.ago) do
            builder = NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
                        .new(school_cohort:)
                        .build
                        .with_validation_data
                        .with_eligibility
                        .with_induction_record(induction_programme: school_cohort.default_induction_programme)

            NewSeeds::Scenarios::Participants::Ects::Ect
              .new(school_cohort:, full_name: "ECT on FIP: after mentor change")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme:, mentor_profile: builder.participant_profile, induction_status: "withdrawn", start_date: 1.day.ago, end_date: Time.zone.now)
              .with_induction_record(induction_programme:, mentor_profile: builder.participant_profile, induction_status: "withdrawn", start_date: Time.zone.now)

            builder
          end
        end

        def mentor_on_fip_withdrawn
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_withdrawn ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: withdrawn by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "withdrawn")
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_enrolled_after_withdraw
          school_cohort = fip_school.school_cohort

          @mentor_on_fip_enrolled_after_withdraw ||= NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: enrolled after being withdrawn")
            .build(status: "withdrawn")
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_withdrawn_no_induction_record
          school_cohort = fip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: withdrawn by lead provider before induction records")
            .build(induction_start_date: nil, training_status: "withdrawn")
            .with_validation_data
            .with_eligibility
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_deferred
          school_cohort = fip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: deferred by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "deferred")
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_withdrawn_from_programme
          school_cohort = fip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: withdrawn from programme")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "withdrawn")
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_completed
          school_cohort = fip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: withdrawn by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "completed")
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        # FIP transfer scenarios

        def mentor_on_fip_leaving
          school_cohort = fip_school.school_cohort

          transfer_date = 1.month.from_now

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: leaving a FIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_left
          school_cohort = fip_school.school_cohort

          transfer_date = 1.month.ago

          travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
              .new(school_cohort:, full_name: "Mentor on FIP: left a FIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
              .add_mentee(induction_programme: school_cohort.default_induction_programme)
          end
        end

        def mentor_on_fip_transferring
          school_cohort = fip_school.school_cohort
          school_cohort_2 = cip_school.school_cohort

          transfer_date = 1.month.from_now

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: transferring from a FIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
            .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_transferred
          school_cohort = fip_school.school_cohort
          school_cohort_2 = cip_school.school_cohort

          transfer_date = 1.month.ago

          travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
              .new(school_cohort:, full_name: "Mentor on FIP: transferred from a FIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
              .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
              .add_mentee(induction_programme: school_cohort.default_induction_programme)
          end
        end

        def mentor_on_fip_joining
          school_cohort = cip_school.school_cohort
          school_cohort_2 = fip_school.school_cohort

          transfer_date = 1.month.from_now

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on FIP: joining a FIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
            .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_fip_joined
          school_cohort = cip_school.school_cohort
          school_cohort_2 = fip_school.school_cohort

          transfer_date = 1.month.ago

          travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
              .new(school_cohort:, full_name: "Mentor on FIP: joined a FIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
              .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
              .add_mentee(induction_programme: school_cohort.default_induction_programme)
          end
        end

        # mentor on CIP

        def mentor_on_cip_no_validation
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: no validation")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_details_request_submitted
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: details request submitted")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_request_for_details_email
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_details_request_failed
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: details request failed")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
            .with_request_for_details_email(status: "temporary-failure")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_details_request_delivered
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: details request delivered")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
            .with_request_for_details_email(status: "delivered")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_validation_api_failure
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: Teacher Qualifications API failure")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_validation_data(api_failure: true)
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_no_tra_record
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: No TRA record found")
            .build(induction_start_date: nil, teacher_profile_args: { trn: nil })
            .with_validation_data
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_manual_check_active_flags
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: requires manual check of active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_manual_check_different_trn
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: requires manual check due to different TRN")
            .build
            .with_validation_data
            .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_manual_check_no_qts
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: with no QTS recorded")
            .build
            .with_validation_data
            .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_eligible_no_qts
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: without QTS")
            .build(sparsity_uplift: true)
            .with_validation_data
            .with_eligibility(no_qts: true, status: "eligible", reason: "no_qts")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_ineligible_active_flags
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: ineligible due to active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_eligible_active_flags
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: eligible despite active flags")
            .build
            .with_validation_data
            .with_eligibility(active_flags: true, status: "eligible", reason: "active_flags")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_ineligible_duplicate_profile
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: ineligible due to duplicate profile")
            .build
            .with_validation_data
            .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_ero_on_cip
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "ERO Mentor on CIP")
            .build
            .with_validation_data
            .with_eligibility(previous_participation: true, status: "ineligible", reason: "previous_participation")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_ero_on_cip_eligible
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "ERO Mentor on CIP: made eligible by DfE")
            .build
            .with_validation_data
            .with_eligibility(previous_participation: true, status: "eligible", reason: "previous_participation")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_no_eligibility_checks
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: no eligibility checks done")
            .build
            .with_validation_data
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_eligible
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: made eligible by DfE")
            .build(sparsity_uplift: true, pupil_premium_uplift: true)
            .with_validation_data
            .with_eligibility(status: "eligible")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_profile_duplicity_primary
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: Primary duplicate profile")
            .build(profile_duplicity: :primary)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_profile_duplicity_secondary
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: Secondary duplicate profile")
            .build(profile_duplicity: :secondary)
            .with_validation_data
            .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP")
            .build(sparsity_uplift: true, pupil_premium_uplift: true)
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_with_no_mentees
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
            .new(school_cohort:, full_name: "Mentor on CIP: no mentees")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_withdrawn
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: withdrawn by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "withdrawn")
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_enrolled_after_withdraw
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: enrolled after being withdrawn")
            .build(status: "withdrawn")
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_withdrawn_no_induction_record
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: withdrawn by lead provider before induction records")
            .build(induction_start_date: nil, training_status: "withdrawn")
            .with_validation_data
            .with_eligibility
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_deferred
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: deferred by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "deferred")
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_withdrawn_from_programme
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: withdrawn from programme")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "withdrawn")
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_completed
          school_cohort = cip_school.school_cohort

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: withdrawn by lead provider")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "completed")
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        # CIP transfer scenarios

        def mentor_on_cip_leaving
          school_cohort = cip_school.school_cohort

          transfer_date = 1.month.from_now

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: leaving a FIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_left
          school_cohort = cip_school.school_cohort

          transfer_date = 1.month.ago

          travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
              .new(school_cohort:, full_name: "Mentor on CIP: left a FIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
              .add_mentee(induction_programme: school_cohort.default_induction_programme)
          end
        end

        def mentor_on_cip_transferring
          school_cohort = cip_school.school_cohort
          school_cohort_2 = fip_school.school_cohort

          transfer_date = 1.month.from_now

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: transferring from a CIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
            .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_transferred
          school_cohort = cip_school.school_cohort
          school_cohort_2 = fip_school.school_cohort

          transfer_date = 1.month.ago

          travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
              .new(school_cohort:, full_name: "Mentor on CIP: transferred from a CIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
              .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
              .add_mentee(induction_programme: school_cohort.default_induction_programme)
          end
        end

        def mentor_on_cip_joining
          school_cohort = fip_school.school_cohort
          school_cohort_2 = cip_school.school_cohort

          transfer_date = 1.month.from_now

          NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
            .new(school_cohort:, full_name: "Mentor on CIP: joining a CIP school")
            .build
            .with_validation_data
            .with_eligibility
            .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
            .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
            .add_mentee(induction_programme: school_cohort.default_induction_programme)
        end

        def mentor_on_cip_joined
          school_cohort = fip_school.school_cohort
          school_cohort_2 = cip_school.school_cohort

          transfer_date = 1.month.ago

          travel_to(2.months.ago) do
            NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
              .new(school_cohort:, full_name: "Mentor on CIP: joined a CIP school")
              .build
              .with_validation_data
              .with_eligibility
              .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
              .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
              .add_mentee(induction_programme: school_cohort.default_induction_programme)
          end
        end
      end
    end
  end
end
