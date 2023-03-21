# frozen_string_literal: true

Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end

RSpec.shared_context "with Training Record state examples", shared_context: :metadata do
  let!(:cohort) { Cohort.current || create(:cohort, :current) }

  let(:cip_school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_cip_with_materials_in(cohort:)
  end
  let(:fip_school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_fip_and_partnered_in(cohort:)
  end

  let(:ect_on_cip_being_trained) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_withdrawn_from_training) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, training_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_cip_having_deferred_their_training) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, training_status: "deferred")
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

  let(:ect_on_fip_with_details_request_submitted) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_request_for_details_email
      .participant_profile
  end

  let(:ect_on_fip_with_details_request_failed) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_request_for_details_email(status: "temporary-failure")
      .participant_profile
  end

  let(:ect_on_fip_with_details_request_delivered) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_request_for_details_email(status: "delivered")
      .participant_profile
  end

  let(:ect_on_fip_after_validation_api_failure) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .participant_profile
  end

  # ect_on_fip_with_tra_record_not_found

  let(:ect_on_fip_who_is_eligible_for_funding) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(status: "eligible")
      .participant_profile
  end

  let(:ect_on_fip_who_needs_active_flags_checking) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "manual_check", reason: "active_flags")
      .participant_profile
  end

  let(:ect_on_fip_who_needs_different_trn_checking) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(different_trn: true, status: "manual_check", reason: "different_trn")
      .participant_profile
  end

  let(:ect_on_fip_who_needs_induction_data_from_ab) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(no_induction: true, status: "manual_check", reason: "no_induction")
      .participant_profile
  end

  let(:ect_on_fip_who_is_waiting_for_qts) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(no_qts: true, status: "manual_check", reason: "no_qts")
      .participant_profile
  end

  # TODO: only a mentor should be in this situation
  let(:ect_on_fip_who_has_no_qts) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(no_qts: true, status: "eligible", reason: "no_qts")
      .participant_profile
  end

  let(:ect_on_fip_who_has_active_flags) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(active_flags: true, status: "ineligible", reason: "active_flags")
      .participant_profile
  end

  let(:ect_on_fip_who_has_duplicate_profile) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(duplicate_profile: true, status: "ineligible", reason: "duplicate_profile")
      .participant_profile
  end

  let(:ect_on_fip_who_is_exempt_from_induction) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(exempt_from_induction: true, status: "ineligible", reason: "exempt_from_induction")
      .participant_profile
  end

  let(:ect_on_fip_who_has_previous_induction) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(previous_induction: true, status: "ineligible", reason: "previous_induction")
      .participant_profile
  end

  let(:ect_on_fip_who_has_previous_participation) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility(previous_participation: true, status: "ineligible", reason: "previous_participation")
      .participant_profile
  end

  let(:ect_on_fip_being_trained) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_withdrawn_from_training) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, training_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_fip_having_deferred_their_training) do
    NewSeeds::Scenarios::Participants::Ects::Ect
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
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_training_record_state_examples
  config.include_context "with Training Record state examples", :with_training_record_state_examples
end
