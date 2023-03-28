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

  let(:ect_on_fip_no_validation) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_no_validation) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_no_validation) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: cip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_details_request_submitted) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_request_for_details_email
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_details_request_submitted) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_request_for_details_email
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_details_request_submitted) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_request_for_details_email
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_details_request_failed) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "temporary-failure")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_details_request_failed) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "temporary-failure")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_details_request_failed) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "temporary-failure")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_details_request_delivered) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "delivered")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_details_request_delivered) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "delivered")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_details_request_delivered) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil }, request_for_details_sent_at: Time.zone.now)
      .with_request_for_details_email(status: "delivered")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_validation_api_failure) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data(api_failure: true)
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_validation_api_failure) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data(api_failure: true)
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_validation_api_failure) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data(api_failure: true)
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_no_tra_record) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_no_tra_record) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_no_tra_record) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(teacher_profile_args: { trn: nil })
      .with_validation_data
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_sparsity_uplift) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(sparsity_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_pupil_premium_uplift) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_no_uplift) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(sparsity_uplift: false, pupil_premium_uplift: false)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_no_uplift) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build(sparsity_uplift: false, pupil_premium_uplift: false)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_manual_check_active_flags) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_manual_check_active_flags) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_manual_check_active_flags) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_manual_check_different_trn) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_manual_check_different_trn) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_manual_check_different_trn) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_manual_check_no_induction) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(no_induction: true, status: "manual_check", reason: "no_induction")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_manual_check_no_induction) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(no_induction: true, status: "manual_check", reason: "no_induction")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_manual_check_no_qts) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_manual_check_no_qts) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_manual_check_no_qts) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_eligible_no_qts) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(sparsity_uplift: true)
      .with_validation_data
      .with_eligibility(no_qts: true, status: "eligible", reason: "no_qts")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_ineligible_active_flags) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_ineligible_active_flags) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_ineligible_active_flags) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_ineligible_duplicate_profile) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_ineligible_duplicate_profile) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_ineligible_duplicate_profile) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_ineligible_exempt_from_induction) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(exempt_from_induction: true, status: "ineligible", reason: "exempt_from_induction")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_ineligible_exempt_from_induction) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(exempt_from_induction: true, status: "ineligible", reason: "exempt_from_induction")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_ineligible_previous_induction) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(previous_induction: true, status: "ineligible", reason: "previous_induction")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_ineligible_previous_induction) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(previous_induction: true, status: "ineligible", reason: "previous_induction")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_ineligible_previous_participation) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(previous_participation: true, status: "ineligible", reason: "previous_participation")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_ineligible_previous_participation) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(previous_participation: true, status: "ineligible", reason: "previous_participation")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  # TODO: does this check look at mentor training as well or just induction training
  let(:mentor_ineligible_previous_participation) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(previous_participation: true, status: "ineligible", reason: "previous_participation")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_no_eligibility_checks) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_no_eligibility_checks) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_eligible) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility(status: "eligible")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_eligible) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(status: "eligible")
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_eligible) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility(status: "eligible")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_profile_duplicity_primary) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(profile_duplicity: :primary)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_profile_duplicity_secondary) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(profile_duplicity: :secondary)
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_no_partnership) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school_no_partnership.school_cohort)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school_no_partnership.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor_no_partnership) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school_no_partnership.school_cohort)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school_no_partnership.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:mentor) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build(sparsity_uplift: true, pupil_premium_uplift: true)
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_withdrawn) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, training_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_cip_withdrawn) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, training_status: "withdrawn")
      .participant_profile
  end

  let(:mentor_withdrawn) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, training_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_fip_enrolled_after_withdraw) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_withdrawn_no_induction_record) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build(training_status: "withdrawn")
      .with_validation_data
      .with_eligibility
      .participant_profile
  end

  let(:ect_on_fip_deferred) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, training_status: "deferred")
      .participant_profile
  end

  let(:ect_on_cip_deferred) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, training_status: "deferred")
      .participant_profile
  end

  let(:mentor_deferred) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, training_status: "deferred")
      .participant_profile
  end

  let(:ect_on_fip_withdrawn_from_programme) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, induction_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_cip_withdrawn_from_programme) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, induction_status: "withdrawn")
      .participant_profile
  end

  let(:mentor_withdrawn_from_programme) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, induction_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_fip_leaving) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, induction_status: "leaving")
      .participant_profile
  end

  let(:ect_on_cip_leaving) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, induction_status: "leaving")
      .participant_profile
  end

  let(:mentor_leaving) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, induction_status: "leaving")
      .participant_profile
  end

  let(:ect_on_fip_completed) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, induction_status: "completed")
      .participant_profile
  end

  let(:ect_on_cip_completed) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, induction_status: "completed")
      .participant_profile
  end

  let(:mentor_completed) do
    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, induction_status: "completed")
      .participant_profile
  end
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_training_record_state_examples
  config.include_context "with Training Record state examples", :with_training_record_state_examples
end
