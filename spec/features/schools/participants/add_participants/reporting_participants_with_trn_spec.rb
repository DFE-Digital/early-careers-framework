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

RSpec.describe "Reporting participants with a known TRN", type: :feature, js: true do
  let!(:cohort) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let!(:next_cohort) { Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022) }
  let!(:current_cohort) { Cohort.current || create(:cohort, :current) }

  let!(:privacy_policy) do
    privacy_policy = create(:privacy_policy)
    PrivacyPolicy::Publish.call
    privacy_policy
  end

  let(:participant_data) do
    {
      trn: "1234567",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1998, 3, 22),
      email: "sally@school.com",
      nino: "",
      start_date: Date.new(2022, 9, 1),
    }
  end

  let!(:school) { create :school, name: "Fip School" }
  let!(:school_cohort) { create :school_cohort, school:, cohort: next_cohort, induction_programme_choice: "full_induction_programme" }
  let!(:induction_programme) do
    induction_programme = create(:induction_programme, :fip, school_cohort:)
    school_cohort.update! default_induction_programme: induction_programme
    induction_programme
  end
  let!(:partnership) do
    create :partnership,
           school:,
           lead_provider: create(:lead_provider, name: "Big Provider Ltd"),
           delivery_partner: create(:delivery_partner, name: "Amazing Delivery Team"),
           cohort: next_cohort,
           challenge_deadline: 2.weeks.ago
  end
  let(:mentor_full_name) { "Billy Mentor" }
  let!(:mentor) do
    user = create(:user, full_name: "Billy Mentor", email: "billy-mentor@example.com")
    teacher_profile = create(:teacher_profile, user:)
    participant_profile_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, school_cohort:)
    Induction::Enrol.call(participant_profile: participant_profile_mentor, induction_programme:)
    Mentors::AddToSchool.call(mentor_profile: participant_profile_mentor, school:)
    participant_profile_mentor
  end
  let!(:induction_coordinator) do
    sit_user = create(:user, full_name: "Fip induction tutor")
    induction_coordinator_profile = create(:induction_coordinator_profile, schools: [school_cohort.school], user: sit_user)
    PrivacyPolicy.current.accept!(sit_user)
    induction_coordinator_profile
  end

  before do
    allow(DqtRecordCheck).to receive(:call).and_return(
      DqtRecordCheck::CheckResult.new(
        valid_dqt_response(participant_data),
        true,
        true,
        true,
        false,
        3,
      ),
    )
  end

  scenario "Adding an ECT validates input" do
    given_i_sign_in_as_the_user_with_the_full_name "Fip induction tutor"
    and_i_view_participant_details_on_the_school_dashboard_page
    and_i_choose_to_add_an_ect_or_mentor_on_the_school_participants_dashboard_page

    when_i_choose_to_add_a_new_ect_on_the_school_add_participant_wizard
    click_on "Continue"
    then_i_see_an_error_message "Enter a full name"

    when_i_add_full_name_to_the_school_add_participant_wizard participant_data[:full_name]
    click_on "Continue"
    then_i_see_an_error_message "Enter the teacher reference number (TRN)"

    when_i_add_teacher_reference_number_to_the_school_add_participant_wizard participant_data[:full_name], participant_data[:trn]
    click_on "Continue"
    then_i_see_an_error_message "Enter a date of birth"

    when_i_add_date_of_birth_to_the_school_add_participant_wizard InvalidDate.new(1983, 2, 29)
    then_i_see_an_error_message "Enter a valid date of birth"

    when_i_add_date_of_birth_to_the_school_add_participant_wizard participant_data[:date_of_birth]
    click_on "Continue"
    then_i_see_an_error_message "Enter an email address"

    when_i_add_email_address_to_the_school_add_participant_wizard "Sally Teacher", participant_data[:email]
    click_on "Continue"
    then_i_see_an_error_message "Choose a mentor"
  end

  scenario "Adding an ECT is accessible" do
    given_i_sign_in_as_the_user_with_the_full_name "Fip induction tutor"
    when_i_view_participant_details_on_the_school_dashboard_page
    then_the_page_is_accessible

    when_i_choose_to_add_an_ect_or_mentor_on_the_school_participants_dashboard_page
    then_the_page_is_accessible

    and_i_choose_to_add_a_new_ect_on_the_school_add_participant_wizard
    then_the_page_is_accessible

    when_i_add_full_name_to_the_school_add_participant_wizard participant_data[:full_name]
    then_the_page_is_accessible

    when_i_add_teacher_reference_number_to_the_school_add_participant_wizard participant_data[:full_name], participant_data[:trn]
    then_the_page_is_accessible

    when_i_add_date_of_birth_to_the_school_add_participant_wizard participant_data[:date_of_birth]
    then_the_page_is_accessible

    when_i_add_email_address_to_the_school_add_participant_wizard "Sally Teacher", participant_data[:email]
    then_the_page_is_accessible

    when_i_choose_a_mentor_from_the_school_add_participant_wizard "Billy Mentor"
    then_the_page_is_accessible

    when_i_confirm_and_add_on_the_school_add_participant_wizard
    then_the_page_is_accessible

    then_i_am_on_the_school_add_participant_completed_page
    and_i_confirm_has_full_name_on_the_school_add_participant_completed_page participant_data[:full_name]
    and_i_confirm_has_participant_type_on_the_school_add_participant_completed_page "ECT"
  end

  scenario "Adding a Mentor is accessible in automatic assignment period" do
    inside_auto_assignment_window do
      given_i_sign_in_as_the_user_with_the_full_name "Fip induction tutor"
      when_i_view_participant_details_from_the_school_dashboard_page

      when_i_choose_to_add_an_ect_or_mentor_from_the_school_participants_dashboard_page
      and_i_choose_to_add_a_new_mentor_on_the_school_add_participant_wizard
      then_the_page_is_accessible

      when_i_add_mentor_full_name_to_the_school_add_participant_wizard participant_data[:full_name]
      when_i_add_teacher_reference_number_to_the_school_add_participant_wizard participant_data[:full_name], participant_data[:trn]
      when_i_add_date_of_birth_to_the_school_add_participant_wizard participant_data[:date_of_birth]

      when_i_add_email_address_to_the_school_add_participant_wizard "Sally Teacher", participant_data[:email]
      then_the_page_is_accessible

      when_i_confirm_and_add_on_the_school_add_participant_wizard
      then_the_page_is_accessible

      then_i_am_on_the_school_add_participant_completed_page
      and_i_confirm_has_full_name_on_the_school_add_participant_completed_page participant_data[:full_name]
      and_i_confirm_has_participant_type_on_the_school_add_participant_completed_page "Mentor"
    end
  end

  scenario "Adding a Mentor is accessible outside automatic assignment period" do
    outside_auto_assignment_window do
      given_i_sign_in_as_the_user_with_the_full_name "Fip induction tutor"
      when_i_view_participant_details_from_the_school_dashboard_page

      when_i_choose_to_add_an_ect_or_mentor_from_the_school_participants_dashboard_page
      and_i_choose_to_add_a_new_mentor_on_the_school_add_participant_wizard
      then_the_page_is_accessible

      when_i_add_mentor_full_name_to_the_school_add_participant_wizard participant_data[:full_name]
      when_i_add_teacher_reference_number_to_the_school_add_participant_wizard participant_data[:full_name], participant_data[:trn]
      when_i_add_date_of_birth_to_the_school_add_participant_wizard participant_data[:date_of_birth]

      when_i_add_email_address_to_the_school_add_participant_wizard "Sally Teacher", participant_data[:email]
      then_the_page_is_accessible

      when_i_choose_summer_term_on_the_school_add_participant_wizard
      then_the_page_is_accessible

      when_i_confirm_and_add_on_the_school_add_participant_wizard
      then_the_page_is_accessible

      then_i_am_on_the_school_add_participant_completed_page
      and_i_confirm_has_full_name_on_the_school_add_participant_completed_page participant_data[:full_name]
      and_i_confirm_has_participant_type_on_the_school_add_participant_completed_page "Mentor"
    end
  end

  def valid_dqt_response(participant_data)
    DqtRecordPresenter.new({
      "name" => participant_data[:full_name],
      "trn" => participant_data[:trn],
      "state_name" => "Active",
      "dob" => participant_data[:date_of_birth],
      "qualified_teacher_status" => { "qts_date" => 1.year.ago },
      "induction" => {
        "start_date" => 1.month.ago,
        "status" => "Active",
      },
    })
  end
end
