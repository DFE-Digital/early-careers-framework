# frozen_string_literal: true

module Steps
  module SetupAScenarioSteps
    def given_a_cohort_with_start_year(year)
      Cohort.find_or_create_by! start_year: year
    end

    def given_a_privacy_policy_has_been_published
      create :privacy_policy
      PrivacyPolicy::Publish.call
    end

    def given_an_ecf_lead_provider(email_address, lead_provider_name)
      ecf_lead_provider = create :lead_provider,
                                 name: lead_provider_name

      create :cpd_lead_provider,
             lead_provider: ecf_lead_provider,
             name: lead_provider_name

      user = create :user,
                    full_name: "#{lead_provider_name}'s Manager",
                    email: email_address

      create :lead_provider_profile,
             user: user,
             lead_provider: ecf_lead_provider

      ecf_lead_provider
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
      and_i_report_a_mistake_from_report_incorrect_partnership_page

      school
    end

    def given_a_cip_school_with_a_partnership_that_has_previously_been_challenged(email_address, school_name, school_slug, challenge_token)
      school = given_a_cip_school_with_a_partnership_that_can_be_challenged email_address, school_name, school_slug, challenge_token
      and_i_use_the_report_incorrect_partnership_token challenge_token
      and_i_report_a_mistake_from_report_incorrect_partnership_page

      school
    end
  end
end
