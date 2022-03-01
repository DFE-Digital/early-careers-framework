# frozen_string_literal: true

module Steps
  module TransferParticipantSteps
    include RSpec::Matchers

    def given_lead_provider_contracted_to_deliver_ecf
      i = @lead_providers.length
      lead_provider = create :lead_provider, :with_delivery_partner
      cpd_lead_provider = create :cpd_lead_provider, lead_provider: lead_provider
      create :ecf_statement, cpd_lead_provider: cpd_lead_provider

      @lead_providers[i] = cpd_lead_provider
      @tokens[cpd_lead_provider.id] = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider, lead_provider: lead_provider)
    end

    def and_another_lead_provider_contracted_to_deliver_ecf
      given_lead_provider_contracted_to_deliver_ecf
    end

    def and_sit_reported_programme(programme)
      i = @sits.length
      school = create :school,
                      name: "#{programme} School #{i}",
                      slug: "111111-#{programme}-school-#{i}",
                      urn: "11111#{i}"
      user = create(:user, full_name: "Carl Coordinator #{i}")
      sit = create :induction_coordinator_profile,
                   schools: [school],
                   user: user
      create :school_cohort, programme,
             school: school,
             cohort: @cohort

      @privacy_policy.accept! sit.user
      @sits[i] = sit
    end

    def and_another_sit_reported_programme(programme)
      and_sit_reported_programme programme
    end

    def and_sit_reported_ect_participant(sit)
      i = @participants.length
      school_cohort = sit.schools.first.school_cohorts.first

      participant = create :ect_participant_profile, school_cohort: school_cohort
      @privacy_policy.accept! participant.user
      @participants[i] = participant
    end

    def and_lead_provider_reported_partnership(cpd_lead_provider, school)
      lead_provider = cpd_lead_provider.lead_provider
      create :partnership,
             school: school,
             lead_provider: lead_provider,
             delivery_partner: lead_provider.delivery_partners.first,
             cohort: @cohort,
             challenge_deadline: 2.weeks.ago
    end

    def and_another_lead_provider_reported_partnership(cpd_lead_provider, school)
      and_lead_provider_reported_partnership cpd_lead_provider, school
    end

    def and_lead_provider_declared_training_started(cpd_lead_provider, participant)
      APIs::ParticipantDeclarationsEndpoint.new(@tokens[cpd_lead_provider.id])
                                   .post_started_declaration(participant)
    end

    def when_sit_takes_on_the_participant(sit, participant)
      school = sit.schools.first
      school_cohort = school.school_cohorts.first

      participant.update!(school_cohort: school_cohort)
      participant.teacher_profile.update!(school: school)
    end

    def then_participant_details_can_be_seen_by_lead_provider(cpd_lead_provider, participant)
      APIs::ECFParticipantsEndpoint.new(@tokens[cpd_lead_provider.id])
                                   .check_can_access_participant_details(participant)

      # TODO: check the individual /participant/#{id} endpoint
    end

    def then_participant_details_cannot_be_seen_by_lead_provider(cpd_lead_provider, participant)
      APIs::ECFParticipantsEndpoint.new(@tokens[cpd_lead_provider.id])
                                   .check_cannot_access_participant_details(participant)

      # TODO: check the individual /participant/#{id} endpoint
    end

    def then_participant_declarations_can_be_seen_by_lead_provider(cpd_lead_provider, participant)
      APIs::ParticipantDeclarationsEndpoint.new(@tokens[cpd_lead_provider.id])
                                   .check_can_access_participant_declarations(participant)

      # TODO: check the individual /declaration/#{id} endpoint
    end

    def then_participant_declarations_cannot_be_seen_by_lead_provider(cpd_lead_provider, participant)
      APIs::ParticipantDeclarationsEndpoint.new(@tokens[cpd_lead_provider.id])
                                   .check_cannot_access_participant_declarations(participant)

      # TODO: check the individual /declaration/#{id} endpoint
    end

    def then_participant_is_fip_ect_for_support_ects(participant)
      APIs::ECFUsersEndpoint.new
                         .check_user_is_fip_ect(participant)
    end

    def then_participant_is_cip_ect_for_support_ects(participant)
      APIs::ECFUsersEndpoint.new
                         .check_user_is_cip_ect(participant)
    end

    def then_participant_can_be_seen_by_cip_sit(sit, participant)
      sign_in_as_sit(sit)
        .check_has_participants
        .navigate_to_participants_dashboard
        .check_can_view_participants(participant)
    end

    def then_participant_cannot_be_seen_by_cip_sit(sit, _participant)
      sign_in_as_sit(sit)
        .check_has_no_participants
    end

    def then_participant_can_be_seen_by_fip_sit(sit, participant)
      sign_in_as_sit(sit)
        .check_has_participants
        .navigate_to_participants_dashboard
        .check_can_view_participants(participant)
    end

    def then_participant_cannot_be_seen_by_fip_sit(sit, _participant)
      sign_in_as_sit(sit)
        .check_has_no_participants
    end

    def sign_in_as_sit(sit)
      sign_in_as sit.user
      Pages::SITInductionDashboard.new(sit)
    end
  end
end
