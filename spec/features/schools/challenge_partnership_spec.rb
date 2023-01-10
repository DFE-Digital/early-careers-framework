# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Reporting an error with a partnership", type: :feature, js: true, rutabaga: false do
  let!(:cohort) { create :cohort, start_year: 2021 }

  let!(:privacy_policy) do
    create :privacy_policy
    PrivacyPolicy::Publish.call
  end

  describe "when using an email link" do
    scenario "Can see challenge options from an email link" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"

      when_i_use_the_report_incorrect_partnership_token "abc1234"

      then_i_am_on_the_report_incorrect_partnership_page_with_token "abc1234"
      and_the_page_is_accessible
    end

    scenario "Can challenge a partnership from an email link" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_use_the_report_incorrect_partnership_token "abc1234"

      when_i_report_a_mistake_on_the_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
      and_the_page_is_accessible
    end

    scenario "Cannot challenge a partnership twice from an email link" do
      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"

      when_i_use_the_report_incorrect_partnership_token "abc1234"

      then_i_am_on_the_report_incorrect_partnership_already_challenged_page
      and_the_page_is_accessible
    end

    scenario "Cannot challenge an expired challenge from an email link" do
      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge "test-sit@example.com", "Test school", "111111-test-school", "abc1234"

      when_i_use_the_report_incorrect_partnership_token "abc1234"

      then_i_am_on_the_report_incorrect_partnership_link_expired_page
      and_the_page_is_accessible
    end
  end

  describe "when the school has chosen a FIP programme" do
    scenario "Can challenge a partnership from the school page" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_sign_in_as_the_user_with_the_email "test-sit@example.com"

      when_i_report_school_has_been_confirmed_incorrectly_on_the_school_dashboard_page
      and_i_report_an_unrecognised_provider_on_the_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Cannot challenge a partnership twice" do
      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_sign_in_as_the_user_with_the_email "test-sit@example.com"

      then_i_confirm_cannot_report_school_has_been_confirmed_incorrectly_on_the_school_dashboard_page
    end

    scenario "Cannot challenge an expired challenge" do
      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_sign_in_as_the_user_with_the_email "test-sit@example.com"

      then_i_confirm_cannot_report_school_has_been_confirmed_incorrectly_on_the_school_dashboard_page
    end
  end

  describe "when the school has chosen a CIP programme" do
    scenario "Can challenge a partnership from the school page" do
      given_a_cip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_sign_in_as_the_user_with_the_email "test-sit@example.com"

      when_i_report_school_has_been_confirmed_incorrectly_on_the_school_dashboard_page
      and_i_report_an_unrecognised_provider_on_the_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end
  end

private

  def given_i_use_the_report_incorrect_partnership_token(challenge_token)
    Pages::ReportIncorrectPartnershipPage.load_from_email challenge_token
  end
  alias_method :when_i_use_the_report_incorrect_partnership_token, :given_i_use_the_report_incorrect_partnership_token
  alias_method :and_i_use_the_report_incorrect_partnership_token, :given_i_use_the_report_incorrect_partnership_token

  def then_i_cannot_report_school_partnership_has_been_confirmed_incorrectly
    page_object = Pages::SchoolPartnershipsPage.loaded
    expect(page_object).to_not be_able_to_report_school_partnership_has_been_confirmed_incorrectly
  end

  def given_a_school(email_address, school_name, school_slug, induction_programme)
    school = create :school,
                    name: school_name,
                    slug: school_slug

    user = create :user,
                  full_name: "#{school_name}'s SIT",
                  email: email_address

    create :induction_coordinator_profile,
           user: user,
           schools: [school]

    PrivacyPolicy.current.accept! user

    sign_in_as user
    choose_programme_wizard = Pages::SchoolReportProgrammeWizard.new
    choose_programme_wizard.complete induction_programme
    sign_out

    if induction_programme == "CIP"
      school_cohort = school.school_cohorts.first
      Induction::SetCohortInductionProgramme.call school_cohort:,
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
    and_i_report_a_mistake_from_the_report_incorrect_partnership_page

    school
  end

  def given_a_cip_school_with_a_partnership_that_has_previously_been_challenged(email_address, school_name, school_slug, challenge_token)
    school = given_a_cip_school_with_a_partnership_that_can_be_challenged email_address, school_name, school_slug, challenge_token
    and_i_use_the_report_incorrect_partnership_token challenge_token
    and_i_report_a_mistake_from_the_report_incorrect_partnership_page

    school
  end
end
