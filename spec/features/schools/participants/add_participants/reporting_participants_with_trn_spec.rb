# frozen_string_literal: true

class InvalidDate
  attr_reader :day, :month, :year

  def initialize(day, month, year)
    @day = day
    @month = month
    @year = year
  end
end

require "rails_helper"

RSpec.describe "Reporting participants with a known TRN",
               with_feature_flags: { change_of_circumstances: "active" },
               type: :feature,
               js: true do
  before do
    given_a_cohort_with_start_year 2021
    given_a_privacy_policy_has_been_published

    given_a_school_that_has_chosen_fip_for_2021_and_partnered

    given_i_authenticate_as_an_induction_coordinator

    @participant_data = {
      trn: "1234567",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1998, 3, 22),
      email: "sally@school.com",
      nino: "",
      start_term: "summer_2022",
      start_date: Date.new(2022, 9, 1),
    }

    allow_any_instance_of(ParticipantValidationService).to receive(:validate)
                                                             .and_return({
                                                               trn: @participant_data[:trn],
                                                               full_name: @participant_data[:full_name],
                                                               nino: nil,
                                                               dob: @participant_data[:date_of_birth],
                                                               config: {},
                                                             })

    given_i_have_added_a_mentor

    then_i_am_on_the_school_dashboard_page
  end

  scenario "Adding an ECT validates input" do
    when_i_add_participant_details_from_school_dashboard_page
    and_i_continue_from_school_add_participant_start_page
    and_i_add_an_ect_from_school_participants_dashboard_page

    when_i_choose_to_add_a_new_ect_from_school_add_participant_wizard
    click_on "Continue"
    then_i_see_an_error_message "Enter a full name"

    when_i_add_full_name_from_school_add_participant_wizard @participant_data[:full_name]
    click_on "Continue"
    then_i_see_an_error_message "Select whether you know the teacher reference number (TRN) for the teacher you are adding"

    when_i_choose_i_know_the_participants_trn_from_school_add_participant_wizard
    click_on "Continue"
    then_i_see_an_error_message "Enter the teacher reference number (TRN) for the teacher you are adding"

    when_i_add_teacher_reference_number_from_school_add_participant_wizard @participant_data[:full_name],
                                                                           @participant_data[:trn]
    click_on "Continue"
    then_i_see_an_error_message "Enter a date of birth"

    when_i_add_date_of_birth_from_school_add_participant_wizard InvalidDate.new(1983, 2, 29)
    then_i_see_an_error_message "Enter a valid date of birth"

    when_i_add_date_of_birth_from_school_add_participant_wizard @participant_data[:date_of_birth]
    click_on "Continue"
    then_i_see_an_error_message "Enter an email address"

    when_i_add_email_address_from_school_add_participant_wizard @participant_data[:email]
    click_on "Continue"
    then_i_see_an_error_message "Choose a start term"

    when_i_choose_start_term_from_school_add_participant_wizard @participant_data[:start_term].humanize
    click_on "Continue"
    then_i_see_an_error_message "Enter the teacher's induction start date"

    when_i_add_start_date_from_school_add_participant_wizard @participant_data[:start_date]
    click_on "Continue"
    then_i_see_an_error_message "Choose a mentor"
  end

  scenario "Adding an ECT is accessible" do
    when_i_add_participant_details_from_school_dashboard_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "ECF roles information"

    when_i_continue_from_school_add_participant_start_page
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT and mentors"

    when_i_add_an_ect_from_school_participants_dashboard_page
    and_i_choose_to_add_a_new_ect_from_school_add_participant_wizard
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT name"

    when_i_add_full_name_from_school_add_participant_wizard @participant_data[:full_name]
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT do you know teachers TRN"

    when_i_choose_i_know_the_participants_trn_from_school_add_participant_wizard
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT trn"

    when_i_add_teacher_reference_number_from_school_add_participant_wizard @participant_data[:full_name],
                                                                           @participant_data[:trn]
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT date of birth"

    when_i_add_date_of_birth_from_school_add_participant_wizard @participant_data[:date_of_birth]
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds ECT email"

    when_i_add_email_address_from_school_add_participant_wizard @participant_data[:email]
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor selects ECT start term"

    when_i_choose_start_term_from_school_add_participant_wizard @participant_data[:start_term].humanize
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor selects ECT induction start date"

    when_i_add_start_date_from_school_add_participant_wizard @participant_data[:start_date]
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor selects ECTs mentor"

    when_i_choose_a_mentor_from_school_add_participant_wizard @participant_profile_mentor.user.full_name.to_s
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor checks ECT details"

    when_i_confirm_and_add_from_school_add_participant_wizard
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor receives add ECT Confirmation"

    then_i_am_on_the_school_add_participant_completed_page
    and_i_confirm_has_full_name_from_school_add_participant_completed_page @participant_data[:full_name]
    and_i_confirm_has_participant_type_from_school_add_participant_completed_page "ECT"
  end

  scenario "Adding a Mentor is accessible" do
    when_i_add_participant_details_from_school_dashboard_page
    and_i_continue_from_school_add_participant_start_page

    when_i_add_a_mentor_from_school_participants_dashboard_page
    and_i_choose_to_add_a_new_mentor_from_school_add_participant_wizard
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor adds mentor name"

    when_i_add_full_name_from_school_add_participant_wizard @participant_data[:full_name]

    when_i_choose_i_know_the_participants_trn_from_school_add_participant_wizard
    when_i_add_teacher_reference_number_from_school_add_participant_wizard @participant_data[:full_name],
                                                                           @participant_data[:trn]

    when_i_add_date_of_birth_from_school_add_participant_wizard @participant_data[:date_of_birth]

    when_i_add_email_address_from_school_add_participant_wizard @participant_data[:email]
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor selects ECT start term"

    when_i_choose_start_term_from_school_add_participant_wizard @participant_data[:start_term].humanize
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor checks mentor details"

    when_i_confirm_and_add_from_school_add_participant_wizard
    then_the_page_is_accessible
    then_percy_is_sent_a_snapshot_named "Induction tutor receives add mentor Confirmation"

    then_i_am_on_the_school_add_participant_completed_page
    and_i_confirm_has_full_name_from_school_add_participant_completed_page @participant_data[:full_name]
    and_i_confirm_has_participant_type_from_school_add_participant_completed_page "Mentor"
  end

private

  def given_a_school_that_has_chosen_fip_for_2021
    @school = create :school,
                     name: "Fip School"

    @school_cohort = create :school_cohort,
                            school: @school,
                            cohort: Cohort.next,
                            induction_programme_choice: "full_induction_programme"

    @induction_programme = create :induction_programme, :fip,
                                  school_cohort: @school_cohort

    @school_cohort.update! default_induction_programme: @induction_programme
  end

  def given_a_school_that_has_chosen_fip_for_2021_and_partnered
    given_a_school_that_has_chosen_fip_for_2021

    @lead_provider = create :lead_provider,
                            name: "Big Provider Ltd"

    @delivery_partner = create :delivery_partner,
                               name: "Amazing Delivery Team"

    create :partnership,
           school: @school,
           lead_provider: @lead_provider,
           delivery_partner: @delivery_partner,
           cohort: Cohort.next,
           challenge_deadline: 2.weeks.ago
  end

  def given_i_have_added_a_mentor
    user = create(:user, full_name: "Billy Mentor", email: "billy-mentor@example.com")
    teacher_profile = create(:teacher_profile, user: user)
    @participant_profile_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile: teacher_profile, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_mentor, induction_programme: @induction_programme)
  end
end
