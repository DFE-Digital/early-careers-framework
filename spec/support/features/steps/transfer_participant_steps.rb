# frozen_string_literal: true

module Steps
  module TransferParticipantSteps
    include RSpec::Matchers

    def given_lead_providers_contracted_to_deliver_ecf(*lead_provider_names)
      lead_provider_names.each do |lead_provider_name|
        user = create :user, full_name: lead_provider_name
        lead_provider = create :lead_provider, :with_delivery_partner, name: lead_provider_name
        cpd_lead_provider = create :cpd_lead_provider, lead_provider: lead_provider
        create :lead_provider_profile, user: user, lead_provider: lead_provider
        create :ecf_statement, cpd_lead_provider: cpd_lead_provider
        token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider, lead_provider: lead_provider)

        lead_providers[lead_provider_name] = cpd_lead_provider
        tokens[lead_provider_name] = token
      end
    end

    def and_sit_reported_programme(sit_name, programme)
      school = create :school, name: "#{sit_name}'s School"
      user = create :user, full_name: sit_name
      sit = create :induction_coordinator_profile,
                   schools: [school],
                   user: user
      privacy_policy.accept! user

      sign_in_as user

      choose_programme_wizard = Pages::SITReportProgrammeWizard.new
      choose_programme_wizard.complete(programme)

      sign_out

      sits[sit_name] = sit
    end

    def and_sit_reported_participant(sit_name, participant_name, participant_type)
      sign_in_as sits[sit_name].user

      inductions_dashboard = Pages::SITInductionDashboard.new
      wizard = inductions_dashboard.start_add_participant_wizard
      wizard.complete(participant_name, participant_type)
      participants_dashboard = wizard.view_participants_dashboard
      participants_dashboard.view_participant participant_name

      sign_out
    end

    def and_participant_has_completed_registration(participant_name)
      year = "1996"
      month = "07"
      day = "02"
      trn = rand(1..9_999_999).to_s.rjust(7, "0")

      user = User.find_by(full_name: participant_name)
      throw "Could not find User for #{participant_name}" if user.nil?

      sign_in_as user

      wizard = Pages::ParticipantRegistrationWizard.new
      wizard.complete participant_name, year, month, day, trn

      sign_out
    end

    def and_lead_provider_reported_partnership(lead_provider_name, sit_name)
      user = User.find_by(full_name: lead_provider_name)
      lead_provider = user.lead_provider
      delivery_partner = lead_provider.delivery_partners.first
      school = sits[sit_name].schools.first

      sign_in_as user

      dashboard = Pages::LeadProviderDashboard.new
      wizard = dashboard.start_confirm_your_schools_wizard
      wizard.complete delivery_partner.name, [school.urn]

      sign_out
    end

    def and_lead_provider_declared_training_started(lead_provider_name, participant_name, _declaration_type)
      declarations_endpoint = APIs::ParticipantDeclarationsEndpoint.new tokens[lead_provider_name]

      user = User.find_by(full_name: participant_name)
      throw "Could not find User for #{participant_name}" if user.nil?
      participant = user.participant_profiles.first

      declarations_endpoint.post_started_declaration participant
    end

    def when_sit_takes_on_the_participant(sit_name, participant_name)
      # TODO: This needs to be automated through the inductions portal when its made

      school = sits[sit_name].schools.first
      school_cohort = school.school_cohorts.first

      user = User.find_by(full_name: participant_name)
      throw "Could not find User for #{participant_name}" if user.nil?
      participant = user.participant_profiles.first

      participant.update! school_cohort: school_cohort
      participant.teacher_profile.update! school: school
    end
  end
end
