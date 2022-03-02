# frozen_string_literal: true

module Steps
  module TransferParticipantSteps
    include RSpec::Matchers

    def given_lead_provider_contracted_to_deliver_ecf
      i = lead_providers.length
      lead_provider = create :lead_provider, :with_delivery_partner
      cpd_lead_provider = create :cpd_lead_provider, lead_provider: lead_provider
      create :ecf_statement, cpd_lead_provider: cpd_lead_provider

      lead_providers[i] = cpd_lead_provider
      tokens[cpd_lead_provider.id] = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider, lead_provider: lead_provider)
    end

    def and_another_lead_provider_contracted_to_deliver_ecf
      given_lead_provider_contracted_to_deliver_ecf
    end

    def and_sit_reported_programme(programme)
      i = sits.length
      school = create :school
      user = create(:user, full_name: "Carl Coordinator #{i}")
      sits[i] = create :induction_coordinator_profile,
                       schools: [school],
                       user: user
      create :school_cohort, programme,
             school: school,
             cohort: cohort

      privacy_policy.accept! sits[i].user
    end

    def and_another_sit_reported_programme(programme)
      and_sit_reported_programme programme
    end

    def and_sit_reported_ect_participant(sit)
      i = participants.length
      school_cohort = sit.schools.first.school_cohorts.first

      participants[i] = create :ect_participant_profile, school_cohort: school_cohort

      privacy_policy.accept! participants[i].user
    end

    def and_lead_provider_reported_partnership(cpd_lead_provider, sit)
      lead_provider = cpd_lead_provider.lead_provider
      school = sit.schools.first

      create :partnership,
             school: school,
             lead_provider: lead_provider,
             delivery_partner: lead_provider.delivery_partners.first,
             cohort: cohort,
             challenge_deadline: 2.weeks.ago
    end

    def and_another_lead_provider_reported_partnership(cpd_lead_provider, school)
      and_lead_provider_reported_partnership cpd_lead_provider, school
    end

    def and_lead_provider_declared_training_started(cpd_lead_provider, participant)
      declarations_endpoint = APIs::ParticipantDeclarationsEndpoint.new(tokens[cpd_lead_provider.id])
      declarations_endpoint.post_started_declaration(participant)
    end

    def when_sit_takes_on_the_participant(sit, participant)
      school = sit.schools.first
      school_cohort = school.school_cohorts.first

      participant.update!(school_cohort: school_cohort)
      participant.teacher_profile.update!(school: school)
    end

    RSpec::Matchers.define :have_details_available_to_lead_provider do |cpd_lead_provider|
      match do |participant|
        declarations_endpoint = APIs::ECFParticipantsEndpoint.new(tokens[cpd_lead_provider.id])
        declarations_endpoint.can_access_participant_details?(participant)
      end

      failure_message do |participant|
        "#{participant} details are not available to #{cpd_lead_provider}"
      end

      failure_message_when_negated do |participant|
        "#{participant} details are available to #{cpd_lead_provider}"
      end

      description do
        "description needed for :have_details_available_to_lead_provider"
      end
    end

    RSpec::Matchers.define :have_declarations_available_to_lead_provider do |cpd_lead_provider|
      match do |participant|
        declarations_endpoint = APIs::ParticipantDeclarationsEndpoint.new(tokens[cpd_lead_provider.id])
        declarations_endpoint.can_access_participant_declarations?(participant)
      end

      failure_message do |participant|
        "#{participant} declarations are not available to #{cpd_lead_provider}"
      end

      failure_message_when_negated do |participant|
        "#{participant} declarations are available to #{cpd_lead_provider}"
      end

      description do
        "description needed for :have_declarations_available_to_lead_provider"
      end
    end

    RSpec::Matchers.define :be_reported_to_support_as_an_ect_on do |programme|
      match do |participant|
        user_endpoint = APIs::ECFUsersEndpoint.new
        if programme == :fip
          user_endpoint.user_is_fip_ect?(participant)
        else
          user_endpoint.user_is_cip_ect?(participant)
        end
      end

      failure_message do |participant|
        "#{participant} is not reported to Support ECTs as an ECT on the #{programme} programme"
      end

      failure_message_when_negated do |participant|
        "#{participant} is reported to Support ECTs as an ECT on the #{programme} programme"
      end

      description do
        "description needed for :be_reported_to_support_as_an_ect_on"
      end
    end

    RSpec::Matchers.define :be_seen_by_sit do |sit|
      match do |participant|
        sign_in_as sit.user

        induction_dashboard = Pages::SITInductionDashboard.new
        induction_dashboard.has_expected_content?(sit) &&
          if induction_dashboard.has_participants?
            participants_dashboard = induction_dashboard.navigate_to_participants_dashboard

            participants_dashboard.has_expected_content? &&
              participants_dashboard.can_view_participants?(participant)
          else
            false
          end
      end

      failure_message do |participant|
        "#{participant} cannot be seen by #{sit}"
      end

      failure_message_when_negated do |participant|
        "#{participant} can be seen by #{sit}"
      end

      description do
        "description needed for :to_be_seen_by_sit"
      end
    end
  end
end
