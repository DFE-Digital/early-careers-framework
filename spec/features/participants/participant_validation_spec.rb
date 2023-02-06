# frozen_string_literal: true

class InvalidDate
  attr_reader :day, :month, :year

  def initialize(day, month, year)
    @day = day
    @month = month
    @year = year
  end
end

RSpec.feature "Participant validation journey",
              with_feature_flags: { eligibility_notifications: "active" },
              type: :feature,
              js: true do
  let(:ect_full_name) { "Lena zavroni" }
  let(:mentor_full_name) { "Spike Spiegel" }

  let(:school_cohort) do
    create :school_cohort, :fip,
           school: create(:school, name: "Awesome school")
  end

  let!(:ect) do
    user = create(:user, full_name: ect_full_name)
    teacher_profile = create(:teacher_profile, user:)

    create :ect_participant_profile,
           teacher_profile:,
           school_cohort:
  end

  let!(:mentor) do
    user = create(:user, full_name: mentor_full_name)
    teacher_profile = create(:teacher_profile, user:)

    create :mentor_participant_profile,
           teacher_profile:,
           school_cohort:
  end

  before do
    allow(ParticipantValidationService).to receive(:validate).and_return nil
  end

  scenario "ECT validation journey validates input" do
    given_i_sign_in_as_the_user_with_the_full_name ect_full_name

    when_i_am_on_the_participant_registration_wizard
    click_on "Continue"
    then_i_see_an_error_message "Enter your teacher reference number (TRN)"

    when_i_add_teacher_reference_number_to_the_participant_registration_wizard ect_full_name, "1234567"
    click_on "Continue"
    then_i_see_an_error_message "Enter your date of birth"

    when_i_add_date_of_birth_to_the_participant_registration_wizard InvalidDate.new(1983, 2, 29)
    then_i_see_an_error_message "Enter valid date of birth"

    when_i_add_date_of_birth_to_the_participant_registration_wizard Date.new(1983, 2, 28)
    and_i_choose_add_your_national_insurance_number_on_the_participant_registration_wizard
    click_on "Continue"
    then_i_see_an_error_message "Enter your National Insurance Number"

    when_i_add_national_insurance_number_to_the_participant_registration_wizard "AB123456C"
    and_i_choose_confirm_your_name_on_the_participant_registration_wizard
    click_on "Continue"
    then_i_see_an_error_message "Select how you want to continue"

    when_i_choose_last_name_has_changed_on_the_participant_registration_wizard
    and_i_add_full_name_to_the_participant_registration_wizard "Correct Name"

    expect(page).to have_content "We still cannot find your details"
  end

  scenario "ECT validation journey is accessible" do
    given_i_sign_in_as_the_user_with_the_full_name ect_full_name
    and_i_am_on_the_participant_registration_wizard
    then_the_page_is_accessible

    when_i_add_teacher_reference_number_to_the_participant_registration_wizard ect_full_name, "1234567"
    then_the_page_is_accessible

    when_i_add_date_of_birth_to_the_participant_registration_wizard Date.new(1983, 2, 28)
    then_the_page_is_accessible

    when_i_choose_add_your_national_insurance_number_on_the_participant_registration_wizard
    then_the_page_is_accessible

    when_i_add_national_insurance_number_to_the_participant_registration_wizard "AB123456C"
    then_the_page_is_accessible

    when_i_choose_confirm_your_name_on_the_participant_registration_wizard
    then_the_page_is_accessible

    when_i_choose_last_name_has_changed_on_the_participant_registration_wizard
    then_the_page_is_accessible

    when_i_add_full_name_to_the_participant_registration_wizard "Correct Name"
    then_i_am_on_the_participant_registration_no_match_page
    and_the_page_is_accessible

    when_i_continue_on_the_participant_registration_no_match_page
    then_i_am_on_the_participant_registration_manual_check_required_page
    and_the_page_is_accessible
  end

  scenario "Mentor validation journey without TRN is accessible" do
    given_i_sign_in_as_the_user_with_the_full_name mentor_full_name
    and_i_am_on_the_mentor_registration_wizard
    and_the_page_is_accessible

    when_i_confirm_do_not_have_trn_on_the_mentor_registration_wizard

    then_i_am_on_the_get_a_trn_page
    and_the_page_is_accessible
  end

  scenario "Mentor validates their details with trn" do
    given_i_sign_in_as_the_user_with_the_full_name mentor_full_name
    and_i_am_on_the_mentor_registration_wizard

    when_i_confirm_have_trn_on_the_mentor_registration_wizard
    and_i_add_teacher_reference_number_to_the_mentor_registration_wizard ect_full_name, "7654321"
    and_i_add_date_of_birth_to_the_mentor_registration_wizard Date.new(1991, 11, 4)
    and_i_choose_add_your_national_insurance_number_to_the_mentor_registration_wizard
    and_i_add_national_insurance_number_to_the_mentor_registration_wizard "AB123456C"
    and_i_choose_confirm_your_name_on_the_mentor_registration_wizard
    and_i_choose_last_name_has_changed_on_the_mentor_registration_wizard
    and_i_add_full_name_to_the_mentor_registration_wizard "Correct Name"

    and_i_am_on_the_participant_registration_no_match_page
    and_i_continue_from_the_participant_registration_no_match_page
    then_i_am_on_the_participant_registration_manual_check_required_page
  end
end
