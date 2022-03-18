# frozen_string_literal: true

module Steps
  module TransferParticipantSteps
    include RSpec::Matchers

    def given_lead_providers_contracted_to_deliver_ecf(lead_provider_name)
      user = create :user, full_name: lead_provider_name
      lead_provider = create :lead_provider, :with_delivery_partner, name: lead_provider_name
      cpd_lead_provider = create :cpd_lead_provider, lead_provider: lead_provider, name: lead_provider_name
      create :lead_provider_profile, user: user, lead_provider: cpd_lead_provider.lead_provider
      create :call_off_contract, lead_provider: cpd_lead_provider.lead_provider

      create :ecf_statement,
             name: "November 2021",
             cpd_lead_provider: cpd_lead_provider

      token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider, lead_provider: lead_provider)

      lead_providers[lead_provider_name] = cpd_lead_provider
      tokens[lead_provider_name] = token
    end

    def and_sit_at_pupil_premium_school_reported_programme(sit_name, programme)
      school = create :school, :pupil_premium_uplift, name: "#{sit_name}'s School"
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
      raise "Could not find User for #{participant_name}" if user.nil?

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

    def and_lead_provider_has_made_training_declaration(lead_provider_name, participant_name, declaration_type)
      response = nil

      user = User.find_by(full_name: participant_name)
      raise "Could not find User for #{participant_name}" if user.nil?

      participant = user.participant_profiles.first
      raise "Could not find ParticipantProfile for #{participant_name}" if participant.nil?

      case declaration_type
      when :started
        timestamp = participant.schedule.milestones.first.start_date + 4.days
        declaration_date = timestamp - 2.days
      when :retained_1
        timestamp = participant.schedule.milestones.second.start_date + 4.days
        declaration_date = timestamp - 2.days
      else
        puts "declaration type was actually #{declaration_type}"
      end

      travel_to(timestamp) do
        declarations_endpoint = APIs::ParticipantDeclarationsEndpoint.new tokens[lead_provider_name]
        response = declarations_endpoint.post_training_declaration participant, declaration_type, declaration_date
      end

      unless !response.nil? &&
          response["declaration_type"].to_sym == declaration_type &&
          response["eligible_for_payment"] == true &&
          response["voided"] == false &&
          response["state"].to_sym == :eligible

        text = JSON.pretty_generate(response)
        raise "eligible training declaration '#{declaration_type}' for '#{participant_name}' by '#{lead_provider_name}' was not in the response\n===\n#{text}\n==="
      end
    end

    def when_sit_takes_on_the_participant(sit_name, participant_name)
      # TODO: This needs to be automated through the inductions portal when its made

      sit = sits[sit_name]
      raise "Could not find User for #{sit_name}" if sit.nil?

      school = sit.schools.first
      raise "Could not find School for #{sit_name}" if school.nil?

      school_cohort = school.school_cohorts.first

      user = User.find_by(full_name: participant_name)
      raise "Could not find User for #{participant_name}" if user.nil?

      participant = user.participant_profiles.first
      raise "Could not find ParticipantProfile for #{participant_name}" if participant.nil?

      participant.update! school_cohort: school_cohort
      participant.teacher_profile.update! school: school
    end

    def and_eligible_training_declarations_are_made_payable
      ParticipantDeclaration.eligible.each do |participant_declaration|
        participant_declaration.make_payable!
        participant_declaration.update! statement: participant_declaration.cpd_lead_provider.statements.first
      end
    end

    def and_lead_provider_statements_have_been_created(lead_provider_name)
      cpd_lead_provider = lead_providers[lead_provider_name]

      nov_statement = cpd_lead_provider.statements.first

      Finance::ECF::CalculationOrchestrator.new(
        statement: nov_statement,
        contract: cpd_lead_provider.lead_provider.call_off_contract,
        aggregator: Finance::ECF::ParticipantAggregator.new(statement: nov_statement),
        calculator: PaymentCalculator::ECF::PaymentCalculation,
      ).call(event_type: :started)
    end
  end
end
