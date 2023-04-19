# frozen_string_literal: true

Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end

RSpec.shared_context "with Training Record state examples", shared_context: :metadata do
  let!(:cohort) { Cohort.current || create(:cohort, :current) }

  let(:fip_school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_fip_and_partnered_in(cohort:)
  end

  let(:fip_school_no_partnership) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_fip_but_not_partnered(cohort:)
  end

  let(:cip_school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_cip_with_materials_in(cohort:)
  end

  # FIP ECTs

  let(:ect_on_fip_no_validation) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_details_request_submitted) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_request_for_details_email
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_details_request_failed) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "temporary-failure")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_details_request_delivered) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "delivered")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_validation_api_failure) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data(api_failure: true)
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_no_tra_record) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_sparsity_uplift) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(sparsity_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_pupil_premium_uplift) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_no_uplift) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(sparsity_uplift: false, pupil_premium_uplift: false)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_manual_check_active_flags) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_manual_check_different_trn) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_manual_check_no_induction) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(no_induction: true, status: "manual_check", reason: "no_induction")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_manual_check_no_qts) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_ineligible_active_flags) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_eligible_active_flags) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "eligible", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_ineligible_duplicate_profile) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_ineligible_exempt_from_induction) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(exempt_from_induction: true, status: "ineligible", reason: "exempt_from_induction")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_ineligible_previous_induction) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(previous_induction: true, status: "ineligible", reason: "previous_induction")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_no_eligibility_checks) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_eligible) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility(status: "eligible")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_no_partnership) do
    school_cohort = fip_school_no_partnership.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_withdrawn) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_fip_enrolled_after_withdraw) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_withdrawn_no_induction_record) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(training_status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .participant_profile
  end

  let(:ect_on_fip_deferred) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "deferred")
      .participant_profile
  end

  let(:ect_on_fip_withdrawn_from_programme) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_fip_completed) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "completed")
      .participant_profile
  end

  # FIP transfer scenarios

  let(:ect_on_fip_leaving) do
    school_cohort = fip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
      .participant_profile
  end

  let(:ect_on_fip_left) do
    school_cohort = fip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Ects::Ect
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
        .participant_profile
    end
  end

  let(:ect_on_fip_transferring) do
    school_cohort = fip_school.school_cohort
    school_cohort_2 = cip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
      .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
      .participant_profile
  end

  let(:ect_on_fip_transferred) do
    school_cohort = fip_school.school_cohort
    school_cohort_2 = cip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Ects::Ect
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
        .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        .participant_profile
    end
  end

  let(:ect_on_fip_joining) do
    school_cohort = cip_school.school_cohort
    school_cohort_2 = fip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
      .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
      .participant_profile
  end

  let(:ect_on_fip_joined) do
    school_cohort = cip_school.school_cohort
    school_cohort_2 = fip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Ects::Ect
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
        .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        .participant_profile
    end
  end

  # CIP ECTs

  let(:ect_on_cip_no_validation) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_details_request_submitted) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_request_for_details_email
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_details_request_failed) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "temporary-failure")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_details_request_delivered) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "delivered")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_validation_api_failure) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data(api_failure: true)
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_no_tra_record) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_no_uplift) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(sparsity_uplift: false, pupil_premium_uplift: false)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_manual_check_active_flags) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_manual_check_different_trn) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_manual_check_no_induction) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(no_induction: true, status: "manual_check", reason: "no_induction")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_manual_check_no_qts) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_ineligible_active_flags) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_eligible_active_flags) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "eligible", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_ineligible_duplicate_profile) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_ineligible_exempt_from_induction) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(exempt_from_induction: true, status: "ineligible", reason: "exempt_from_induction")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_ineligible_previous_induction) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(previous_induction: true, status: "ineligible", reason: "previous_induction")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_no_eligibility_checks) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_eligible) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(status: "eligible")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_withdrawn) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_cip_enrolled_after_withdraw) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_withdrawn_no_induction_record) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build(training_status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .participant_profile
  end

  let(:ect_on_cip_deferred) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "deferred")
      .participant_profile
  end

  let(:ect_on_cip_withdrawn_from_programme) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_cip_completed) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "completed")
      .participant_profile
  end

  # CIP transfer scenarios

  let(:ect_on_cip_leaving) do
    school_cohort = cip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
      .participant_profile
  end

  let(:ect_on_cip_left) do
    school_cohort = cip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Ects::Ect
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
        .participant_profile
    end
  end

  let(:ect_on_cip_transferring) do
    school_cohort = cip_school.school_cohort
    school_cohort_2 = fip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
      .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
      .participant_profile
  end

  let(:ect_on_cip_transferred) do
    school_cohort = cip_school.school_cohort
    school_cohort_2 = fip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Ects::Ect
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
        .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        .participant_profile
    end
  end

  let(:ect_on_cip_joining) do
    school_cohort = fip_school.school_cohort
    school_cohort_2 = cip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
      .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
      .participant_profile
  end

  let(:ect_on_cip_joined) do
    school_cohort = fip_school.school_cohort
    school_cohort_2 = cip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Ects::Ect
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
        .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        .participant_profile
    end
  end

  # mentor of FIP

  let(:mentor_on_fip_no_validation) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_details_request_submitted) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_request_for_details_email
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_details_request_failed) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "temporary-failure")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_details_request_delivered) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "delivered")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_validation_api_failure) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data(api_failure: true)
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_no_tra_record) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_manual_check_active_flags) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_manual_check_different_trn) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_manual_check_no_qts) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_eligible_no_qts) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(sparsity_uplift: true)
      .with_validation_data
      .with_eligibility(no_qts: true, status: "eligible", reason: "no_qts")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_ineligible_active_flags) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_eligible_active_flags) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "eligible", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_ineligible_duplicate_profile) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_ero_on_fip) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(previous_participation: true, status: "ineligible", reason: "previous_participation")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_ero_on_fip_eligible) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(previous_participation: true, status: "eligible", reason: "previous_participation")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_no_eligibility_checks) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_eligible) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility(status: "eligible")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_profile_duplicity_primary) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(profile_duplicity: :primary)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_profile_duplicity_secondary) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(profile_duplicity: :secondary)
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_no_partnership) do
    school_cohort = fip_school_no_partnership.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_with_no_mentees) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_withdrawn) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "withdrawn")
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_enrolled_after_withdraw) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_withdrawn_no_induction_record) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(training_status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_deferred) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "deferred")
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_withdrawn_from_programme) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "withdrawn")
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_completed) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "completed")
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  # FIP transfer scenarios

  let(:mentor_on_fip_leaving) do
    school_cohort = fip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_left) do
    school_cohort = fip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
        .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
    end
  end

  let(:mentor_on_fip_transferring) do
    school_cohort = fip_school.school_cohort
    school_cohort_2 = cip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
      .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_transferred) do
    school_cohort = fip_school.school_cohort
    school_cohort_2 = cip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
        .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
    end
  end

  let(:mentor_on_fip_joining) do
    school_cohort = cip_school.school_cohort
    school_cohort_2 = fip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
      .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_fip_joined) do
    school_cohort = cip_school.school_cohort
    school_cohort_2 = fip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
        .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
    end
  end

  # mentor on CIP

  let(:mentor_on_cip_no_validation) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_details_request_submitted) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_request_for_details_email
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_details_request_failed) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "temporary-failure")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_details_request_delivered) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "delivered")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_validation_api_failure) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data(api_failure: true)
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_no_tra_record) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_manual_check_active_flags) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_manual_check_different_trn) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_manual_check_no_qts) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_eligible_no_qts) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(sparsity_uplift: true)
      .with_validation_data
      .with_eligibility(no_qts: true, status: "eligible", reason: "no_qts")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_ineligible_active_flags) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_eligible_active_flags) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "eligible", reason: "active_flags")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_ineligible_duplicate_profile) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_ero_on_cip) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(previous_participation: true, status: "ineligible", reason: "previous_participation")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_ero_on_cip_eligible) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility(previous_participation: true, status: "eligible", reason: "previous_participation")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_no_eligibility_checks) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_eligible) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility(status: "eligible")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_profile_duplicity_primary) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(profile_duplicity: :primary)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_profile_duplicity_secondary) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(profile_duplicity: :secondary)
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_with_no_mentees) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_withdrawn) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "withdrawn")
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_enrolled_after_withdraw) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_withdrawn_no_induction_record) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build(training_status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_deferred) do
    school_cohort = fip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, training_status: "deferred")
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_withdrawn_from_programme) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "withdrawn")
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_completed) do
    school_cohort = cip_school.school_cohort

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "completed")
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  # CIP transfer scenarios

  let(:mentor_on_cip_leaving) do
    school_cohort = cip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_left) do
    school_cohort = cip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date)
        .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
    end
  end

  let(:mentor_on_cip_transferring) do
    school_cohort = cip_school.school_cohort
    school_cohort_2 = fip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
      .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_transferred) do
    school_cohort = cip_school.school_cohort
    school_cohort_2 = fip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
        .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
    end
  end

  let(:mentor_on_cip_joining) do
    school_cohort = fip_school.school_cohort
    school_cohort_2 = cip_school.school_cohort

    transfer_date = 1.month.from_now

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
      .new(school_cohort:)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
      .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
      .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_on_cip_joined) do
    school_cohort = fip_school.school_cohort
    school_cohort_2 = cip_school.school_cohort

    transfer_date = 1.month.ago

    travel_to(2.months.ago) do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts
        .new(school_cohort:)
        .build
        .with_validation_data
        .with_eligibility
        .with_induction_record(induction_programme: school_cohort.default_induction_programme, induction_status: "leaving", end_date: transfer_date, school_transfer: true)
        .with_induction_record(induction_programme: school_cohort_2.default_induction_programme, start_date: transfer_date, school_transfer: true)
        .add_mentee(induction_programme: school_cohort.default_induction_programme)
      .participant_profile
    end
  end
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_training_record_state_examples
  config.include_context "with Training Record state examples", :with_training_record_state_examples
end
