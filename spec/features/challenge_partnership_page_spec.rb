# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Reporting an error with a partnership", type: :feature, js: true, rutabaga: false do
  let(:cohort) { Cohort.find_or_create_by! start_year: 2021 }

  before(:each) do
    PrivacyPolicy.find_or_create_by! major_version: 1, minor_version: 0, html: "PrivacyPolicy"
    @scenario = Time.zone.now.to_i
  end

  describe "when using an email link" do
    scenario "Can see challenge options from an email link" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario, cohort

      when_i_use_the_report_incorrect_partnership_email_link "abc123_#{@scenario}"

      then_i_am_on_the_report_incorrect_partnership_page_with_token "abc123_#{@scenario}"
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge options"
    end

    scenario "Can challenge a partnership from an email link" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario, cohort
      and_i_use_the_report_incorrect_partnership_email_link "abc123_#{@scenario}"
      and_i_am_on_the_report_incorrect_partnership_page_with_token "abc123_#{@scenario}"

      when_i_report_a_mistake

      then_i_am_on_the_report_incorrect_partnership_success_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge success"
    end

    scenario "Cannot challenge a partnership twice from an email link" do
      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged @scenario, cohort

      when_i_use_the_report_incorrect_partnership_email_link "abc123_#{@scenario}"

      then_i_am_on_the_report_incorrect_partnership_already_challenged_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "already challenged"
    end

    scenario "Cannot challenge an expired challenge from an email link" do
      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge @scenario, cohort

      when_i_use_the_report_incorrect_partnership_email_link "abc123_#{@scenario}"

      then_i_am_on_the_report_incorrect_partnership_link_expired_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge link expired"
    end
  end

  describe "when the school has chosen a FIP programme" do
    scenario "Can challenge a partnership from the school page" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario, cohort
      and_i_authenticate_as_a_sit_with_the_email "test-sit-#{@scenario}@example.com"

      when_i_report_that_the_school_has_been_confirmed_incorrectly
      and_i_report_an_unrecognised_provider

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Can challenge a partnership by entering the partnerships URL" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario, cohort
      and_i_authenticate_as_a_sit_with_the_email "test-sit-#{@scenario}@example.com"

      when_i_view_the_programme_details
      and_i_view_the_training_partnership_details
      and_i_report_an_unrecognised_provider

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Cannot challenge a partnership twice" do
      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged @scenario, cohort
      and_i_authenticate_as_a_sit_with_the_email "test-sit-#{@scenario}@example.com"

      then_i_cannot_report_that_the_school_has_been_confirmed_incorrectly
    end

    scenario "Cannot challenge an expired challenge" do
      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge @scenario, cohort
      and_i_authenticate_as_a_sit_with_the_email "test-sit-#{@scenario}@example.com"

      then_i_cannot_report_that_the_school_has_been_confirmed_incorrectly
    end
  end

  describe "when the school has chosen a CIP programme" do
    scenario "Can challenge a partnership from the school page" do
      given_a_cip_school_with_a_partnership_that_can_be_challenged @scenario, cohort
      and_i_authenticate_as_a_sit_with_the_email "test-sit-#{@scenario}@example.com"

      when_i_report_that_the_school_has_been_confirmed_incorrectly
      and_i_report_an_unrecognised_provider

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Can challenge a partnership by entering the partnerships URL" do
      given_a_cip_school_with_a_partnership_that_can_be_challenged @scenario, cohort
      and_i_authenticate_as_a_sit_with_the_email "test-sit-#{@scenario}@example.com"

      when_i_view_the_programme_details
      and_i_view_the_training_partnership_details
      and_i_report_an_unrecognised_provider

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Cannot challenge a partnership twice" do
      given_a_cip_school_with_a_partnership_that_has_previously_been_challenged @scenario, cohort
      and_i_authenticate_as_a_sit_with_the_email "test-sit-#{@scenario}@example.com"

      then_i_cannot_report_that_the_school_has_been_confirmed_incorrectly
    end

    scenario "Cannot challenge an expired challenge" do
      given_a_cip_school_with_a_partnership_that_has_an_expired_challenge @scenario, cohort
      and_i_authenticate_as_a_sit_with_the_email "test-sit-#{@scenario}@example.com"

      then_i_cannot_report_that_the_school_has_been_confirmed_incorrectly
    end
  end

private

  def given_a_school(scenario_id, _cohort, induction_programme)
    email_address = "test-sit-#{scenario_id}@example.com"
    school_name = "Test school #{scenario_id}"
    school_slug = "11111#{scenario_id}-test-school-#{scenario_id}"

    school = create :school,
                    name: school_name,
                    slug: school_slug

    user = create :user,
                  :induction_coordinator,
                  schools: [school],
                  email: email_address

    PrivacyPolicy.current.accept! user

    sign_in_as user
    choose_programme_wizard = Pages::SITReportProgrammeWizard.new
    choose_programme_wizard.complete induction_programme
    sign_out

    if induction_programme == "CIP"
      school_cohort = school.school_cohorts.first
      Induction::SetCohortInductionProgramme.call school_cohort: school_cohort,
                                                  programme_choice: school_cohort.induction_programme_choice
    end

    school
  end

  def given_a_partnership(scenario_id, cohort, school, expired: false)
    created_date = 20.days.ago
    challenge_token = "abc123_#{scenario_id}"

    delivery_partner = create :delivery_partner,
                              name: "Test delivery partner #{scenario_id}"

    partnership = if expired
                    create :partnership,
                           challenge_deadline: created_date + 14.days,
                           school: school,
                           cohort: cohort,
                           delivery_partner: delivery_partner,
                           created_at: created_date
                  else
                    create :partnership,
                           :in_challenge_window,
                           school: school,
                           cohort: cohort,
                           delivery_partner: delivery_partner,
                           created_at: created_date
                  end

    PartnershipNotificationEmail.create! token: challenge_token,
                                         sent_to: school.induction_coordinators.first.email,
                                         partnership: partnership,
                                         email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
                                         created_at: created_date

    delivery_partner
  end

  def given_a_fip_school(scenario_id, cohort)
    given_a_school scenario_id, cohort, "FIP"
  end

  def given_a_cip_school(scenario_id, cohort)
    given_a_school scenario_id, cohort, "CIP"
  end

  def given_a_partnership_that_can_be_challenged(scenario_id, cohort, school)
    given_a_partnership scenario_id, cohort, school
  end

  def given_a_partnership_that_has_an_expired_challenge(scenario_id, cohort, school)
    given_a_partnership scenario_id, cohort, school, expired: true
  end

  def given_a_fip_school_with_a_partnership_that_can_be_challenged(scenario_id, cohort)
    school = given_a_fip_school scenario_id, cohort
    given_a_partnership_that_can_be_challenged scenario_id, cohort, school
  end

  def given_a_fip_school_with_a_partnership_that_has_an_expired_challenge(scenario_id, cohort)
    school = given_a_fip_school scenario_id, cohort
    given_a_partnership_that_has_an_expired_challenge scenario_id, cohort, school
  end

  def given_a_fip_school_with_a_partnership_that_has_previously_been_challenged(scenario_id, cohort)
    delivery_partner = given_a_fip_school_with_a_partnership_that_can_be_challenged scenario_id, cohort
    given_i_use_the_report_incorrect_partnership_email_link "abc123_#{scenario_id}"
    when_i_report_a_mistake

    delivery_partner
  end

  def given_a_cip_school_with_a_partnership_that_can_be_challenged(scenario_id, cohort)
    school = given_a_cip_school scenario_id, cohort
    given_a_partnership_that_can_be_challenged scenario_id, cohort, school
  end

  def given_a_cip_school_with_a_partnership_that_has_an_expired_challenge(scenario_id, cohort)
    school = given_a_cip_school scenario_id, cohort
    given_a_partnership_that_has_an_expired_challenge scenario_id, cohort, school
  end

  def given_a_cip_school_with_a_partnership_that_has_previously_been_challenged(scenario_id, cohort)
    delivery_partner = given_a_cip_school_with_a_partnership_that_can_be_challenged scenario_id, cohort
    given_i_use_the_report_incorrect_partnership_email_link "abc123_#{scenario_id}"
    when_i_report_a_mistake

    delivery_partner
  end

  def when_i_view_the_school_cohorts_page
    raise "method <when_i_view_the_school_cohorts_page> not implemented yet"
  end
  alias_method :and_i_view_the_school_cohorts_page, :when_i_view_the_school_cohorts_page

  def when_i_view_the_training_partnership_details
    visit "#{page.current_url}/partnerships"
    page_object = Pages::SchoolPartnershipsPage.loaded
    page_object.report_school_has_been_confirmed_incorrectly
  end
  alias_method :and_i_view_the_training_partnership_details, :when_i_view_the_training_partnership_details

  def when_i_view_the_programme_details
    page_object = Pages::SchoolPage.loaded
    page_object.view_programme_details
  end
  alias_method :and_i_view_the_programme_details, :when_i_view_the_programme_details

  def when_i_report_a_mistake
    page_object = Pages::ReportIncorrectPartnershipPage.loaded
    page_object.report_a_mistake
  end
  alias_method :and_i_report_a_mistake, :when_i_report_a_mistake

  def when_i_report_an_unrecognised_provider
    page_object = Pages::ReportIncorrectPartnershipPage.loaded
    page_object.report_an_unrecognised_provider
  end
  alias_method :and_i_report_an_unrecognised_provider, :when_i_report_an_unrecognised_provider

  def when_i_report_that_the_school_has_been_confirmed_incorrectly
    page_object = Pages::SchoolPage.loaded
    page_object.report_school_has_been_confirmed_incorrectly
  end
  alias_method :and_i_report_that_the_school_has_been_confirmed_incorrectly, :when_i_report_that_the_school_has_been_confirmed_incorrectly

  def then_i_cannot_report_that_the_school_has_been_confirmed_incorrectly
    expect(page).to_not have_content "report that your school has been confirmed incorrectly"
  end
end
