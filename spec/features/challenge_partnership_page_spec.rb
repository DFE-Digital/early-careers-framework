# frozen_string_literal: true

require "rails_helper"

class ChallengePartnershipScenario
  attr_reader :number,
              :sit_email_address,
              :school_name,
              :school_slug,
              :partnership_challenge_token

  def initialize(num)
    @number = num

    @sit_email_address = "test-sit-#{num}@example.com"

    @school_name = "Test school #{num}"
    @school_slug = "111111-test-school-#{num}"

    @partnership_challenge_token = "abc123_#{num}"
  end
end

RSpec.feature "Reporting an error with a partnership", type: :feature, js: true, rutabaga: false do
  before do
    given_a_cohort_with_start_year 2021
    given_a_privacy_policy_has_been_published
  end

  describe "when using an email link" do
    scenario "Can see challenge options from an email link" do
      @scenario = ChallengePartnershipScenario.new(1)

      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token

      when_i_use_the_report_incorrect_partnership_token @scenario.partnership_challenge_token

      then_i_am_on_the_report_incorrect_partnership_page_with_token @scenario.partnership_challenge_token
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge options"
    end

    scenario "Can challenge a partnership from an email link" do
      @scenario = ChallengePartnershipScenario.new(2)

      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_use_the_report_incorrect_partnership_token @scenario.partnership_challenge_token
      and_i_am_on_the_report_incorrect_partnership_page_with_token @scenario.partnership_challenge_token

      when_i_report_a_mistake

      then_i_am_on_the_report_incorrect_partnership_success_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge success"
    end

    scenario "Cannot challenge a partnership twice from an email link" do
      @scenario = ChallengePartnershipScenario.new(3)

      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token

      when_i_use_the_report_incorrect_partnership_token @scenario.partnership_challenge_token

      then_i_am_on_the_report_incorrect_partnership_already_challenged_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "already challenged"
    end

    scenario "Cannot challenge an expired challenge from an email link" do
      @scenario = ChallengePartnershipScenario.new(4)

      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token

      when_i_use_the_report_incorrect_partnership_token @scenario.partnership_challenge_token

      then_i_am_on_the_report_incorrect_partnership_link_expired_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge link expired"
    end
  end

  describe "when the school has chosen a FIP programme" do
    scenario "Can challenge a partnership from the school page" do
      @scenario = ChallengePartnershipScenario.new(5)

      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_a_sit_with_the_email @scenario.sit_email_address

      when_i_report_that_the_school_has_been_confirmed_incorrectly
      and_i_report_an_unrecognised_provider

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Can challenge a partnership by entering the partnerships URL" do
      @scenario = ChallengePartnershipScenario.new(6)

      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_a_sit_with_the_email @scenario.sit_email_address

      when_i_view_the_programme_details
      and_i_view_the_training_partnership_details
      and_i_report_an_unrecognised_provider

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Cannot challenge a partnership twice" do
      @scenario = ChallengePartnershipScenario.new(7)

      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_a_sit_with_the_email @scenario.sit_email_address

      then_i_cannot_report_that_the_school_has_been_confirmed_incorrectly
    end

    scenario "Cannot challenge an expired challenge" do
      @scenario = ChallengePartnershipScenario.new(8)

      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_a_sit_with_the_email @scenario.sit_email_address

      then_i_cannot_report_that_the_school_has_been_confirmed_incorrectly
    end
  end

  describe "when the school has chosen a CIP programme" do
    scenario "Can challenge a partnership from the school page" do
      @scenario = ChallengePartnershipScenario.new(9)

      given_a_cip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_a_sit_with_the_email @scenario.sit_email_address

      when_i_report_that_the_school_has_been_confirmed_incorrectly
      and_i_report_an_unrecognised_provider

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Can challenge a partnership by entering the partnerships URL" do
      @scenario = ChallengePartnershipScenario.new(10)

      given_a_cip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_a_sit_with_the_email @scenario.sit_email_address

      when_i_view_the_programme_details
      and_i_view_the_training_partnership_details
      and_i_report_an_unrecognised_provider

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Cannot challenge a partnership twice" do
      @scenario = ChallengePartnershipScenario.new(11)

      given_a_cip_school_with_a_partnership_that_has_previously_been_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_a_sit_with_the_email @scenario.sit_email_address

      then_i_cannot_report_that_the_school_has_been_confirmed_incorrectly
    end

    scenario "Cannot challenge an expired challenge" do
      @scenario = ChallengePartnershipScenario.new(12)

      given_a_cip_school_with_a_partnership_that_has_an_expired_challenge @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_a_sit_with_the_email @scenario.sit_email_address

      then_i_cannot_report_that_the_school_has_been_confirmed_incorrectly
    end
  end

private

  def given_a_cohort_with_start_year(year)
    Cohort.find_or_create_by! start_year: year
  end

  def given_a_privacy_policy_has_been_published
    create :privacy_policy
    PrivacyPolicy::Publish.call
  end

  def given_a_school(email_address, school_name, school_slug, induction_programme)
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

  def given_a_partnership(challenge_token, school, expired: false)
    created_date = 20.days.ago

    delivery_partner = create :delivery_partner,
                              name: "Test delivery partner"

    school_cohort = school.school_cohorts.first

    partnership = if expired
                    create :partnership,
                           challenge_deadline: created_date + 14.days,
                           school: school,
                           cohort: school_cohort.cohort,
                           delivery_partner: delivery_partner,
                           created_at: created_date
                  else
                    create :partnership,
                           :in_challenge_window,
                           school: school,
                           cohort: school_cohort.cohort,
                           delivery_partner: delivery_partner,
                           created_at: created_date
                  end

    PartnershipNotificationEmail.create! token: challenge_token,
                                         sent_to: school.induction_coordinators.first.email,
                                         partnership: partnership,
                                         email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
                                         created_at: created_date

    partnership
  end

  def given_a_fip_school(email_address, school_name, school_slug)
    given_a_school email_address, school_name, school_slug, "FIP"
  end

  def given_a_cip_school(email_address, school_name, school_slug)
    given_a_school email_address, school_name, school_slug, "CIP"
  end

  def given_a_partnership_that_can_be_challenged(challenge_token, school)
    given_a_partnership challenge_token, school
  end
  alias_method :and_a_partnership_that_can_be_challenged, :given_a_partnership_that_can_be_challenged

  def given_a_partnership_that_has_an_expired_challenge(challenge_token, school)
    given_a_partnership challenge_token, school, expired: true
  end
  alias_method :and_a_partnership_that_has_an_expired_challenge, :given_a_partnership_that_has_an_expired_challenge

  def given_a_fip_school_with_a_partnership_that_can_be_challenged(email_address, school_name, school_slug, challenge_token)
    school = given_a_fip_school email_address, school_name, school_slug
    and_a_partnership_that_can_be_challenged challenge_token, school

    school
  end

  def given_a_fip_school_with_a_partnership_that_has_an_expired_challenge(email_address, school_name, school_slug, challenge_token)
    school = given_a_fip_school email_address, school_name, school_slug
    and_a_partnership_that_has_an_expired_challenge challenge_token, school

    school
  end

  def given_a_cip_school_with_a_partnership_that_can_be_challenged(email_address, school_name, school_slug, challenge_token)
    school = given_a_cip_school email_address, school_name, school_slug
    and_a_partnership_that_can_be_challenged challenge_token, school

    school
  end

  def given_a_cip_school_with_a_partnership_that_has_an_expired_challenge(email_address, school_name, school_slug, challenge_token)
    school = given_a_cip_school email_address, school_name, school_slug
    and_a_partnership_that_has_an_expired_challenge challenge_token, school

    school
  end

  def given_a_fip_school_with_a_partnership_that_has_previously_been_challenged(email_address, school_name, school_slug, challenge_token)
    school = given_a_fip_school_with_a_partnership_that_can_be_challenged email_address, school_name, school_slug, challenge_token
    and_i_use_the_report_incorrect_partnership_token challenge_token
    and_i_report_a_mistake

    school
  end

  def given_a_cip_school_with_a_partnership_that_has_previously_been_challenged(email_address, school_name, school_slug, challenge_token)
    school = given_a_cip_school_with_a_partnership_that_can_be_challenged email_address, school_name, school_slug, challenge_token
    and_i_use_the_report_incorrect_partnership_token challenge_token
    and_i_report_a_mistake

    school
  end

  def when_i_view_the_training_partnership_details
    page_object = Pages::SchoolCohortsPage.loaded
    page_object = page_object.enter_partnership_details_url
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
