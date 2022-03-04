# frozen_string_literal: true

module Steps
  module TransferParticipantSteps
    include RSpec::Matchers

    def given_lead_providers_contracted_to_deliver_ecf(*lead_provider_names)
      lead_provider_names.each do |lead_provider_name|
        lead_provider = create :lead_provider, :with_delivery_partner, name: lead_provider_name
        cpd_lead_provider = create :cpd_lead_provider, lead_provider: lead_provider
        create :ecf_statement, cpd_lead_provider: cpd_lead_provider

        lead_providers[lead_provider_name] = cpd_lead_provider
        tokens[lead_provider_name] = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider, lead_provider: lead_provider)
      end
    end

    def and_sit_reported_programme(sit_name, programme)
      school = create :school, name: "#{sit_name}'s School"
      user = create :user, full_name: sit_name
      sits[sit_name] = create :induction_coordinator_profile,
                              schools: [school],
                              user: user

      # TODO: this should be done through the UI

      create :school_cohort, programme.downcase.to_sym,
             school: school,
             cohort: cohort

      privacy_policy.accept! sits[sit_name].user
    end

    def and_sit_reported_ect_participant(sit_name, participant_name, participant_type)
      # TODO: this should be done through the UI

      school_cohort = sits[sit_name].schools.first.school_cohorts.first

      participants[participant_name] = create :"#{participant_type.downcase.to_sym}_participant_profile",
                                              school_cohort: school_cohort

      privacy_policy.accept! participants[participant_name].user
    end

    def and_lead_provider_reported_partnership(lead_provider_name, sit_name)
      # TODO: This should be done through the UI

      lead_provider = lead_providers[lead_provider_name].lead_provider
      school = sits[sit_name].schools.first

      create :partnership,
             school: school,
             lead_provider: lead_provider,
             delivery_partner: lead_provider.delivery_partners.first,
             cohort: cohort,
             challenge_deadline: 2.weeks.ago
    end

    def and_lead_provider_declared_training_started(lead_provider_name, participant_name, _declaration_type)
      declarations_endpoint = APIs::ParticipantDeclarationsEndpoint.new(tokens[lead_provider_name])
      declarations_endpoint.post_started_declaration(participants[participant_name])
    end

    def when_sit_takes_on_the_participant(sit_name, participant_name)
      # TODO: This needs to be automated through the inductions portal when its made

      school = sits[sit_name].schools.first
      school_cohort = school.school_cohorts.first

      participants[participant_name].update!(school_cohort: school_cohort)
      participants[participant_name].teacher_profile.update!(school: school)
    end
  end
end
