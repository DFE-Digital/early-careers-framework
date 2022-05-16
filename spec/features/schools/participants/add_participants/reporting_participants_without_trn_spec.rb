# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reporting participants without a known TRN",
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

    given_i_have_added_a_mentor

    then_i_am_on_the_school_dashboard_page
  end

  scenario "Adding an ECT" do
    when_i_report_a_new_ect_at_the_school

    then_i_am_on_the_school_add_participant_completed_page
    and_i_confirm_has_full_name_from_school_add_participant_completed_page @participant_data[:full_name]
    and_i_confirm_has_participant_type_from_school_add_participant_completed_page "ECT"
  end

  scenario "Adding a mentor" do
    when_i_report_a_new_mentor_at_the_school

    then_i_am_on_the_school_add_participant_completed_page
    and_i_confirm_has_full_name_from_school_add_participant_completed_page @participant_data[:full_name]
    and_i_confirm_has_participant_type_from_school_add_participant_completed_page "mentor"
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

  def when_i_report_a_new_ect_at_the_school
    Pages::SchoolDashboardPage.loaded
                              .add_participant_details
                              .continue
                              .add_an_ect
                              .add_ect @participant_data[:full_name],
                                       @participant_data[:email],
                                       @participant_data[:start_term].humanize,
                                       @participant_data[:start_date],
                                       nil,
                                       nil,
                                       @participant_profile_mentor.user.full_name.to_s
  end

  def when_i_report_a_new_mentor_at_the_school
    Pages::SchoolDashboardPage.loaded
                              .add_participant_details
                              .continue
                              .add_a_mentor
                              .add_mentor @participant_data[:full_name],
                                          @participant_data[:email],
                                          @participant_data[:start_term].humanize,
                                          @participant_data[:start_date]
  end
end
