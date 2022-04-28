# frozen_string_literal: true

module Steps
  module ChangesOfCircumstanceSteps
    include RSpec::Matchers

    def given_lead_providers_contracted_to_deliver_ecf(lead_provider_name)
      next_ideal_time Time.zone.local(2021, 2, 1, 9, 0, 0)

      travel_to(@timestamp) do
        user = create :user, full_name: lead_provider_name
        lead_provider = create :lead_provider, :with_delivery_partner, name: lead_provider_name
        cpd_lead_provider = create :cpd_lead_provider, lead_provider: lead_provider, name: lead_provider_name
        create :lead_provider_profile, user: user, lead_provider: cpd_lead_provider.lead_provider
        create :call_off_contract, lead_provider: cpd_lead_provider.lead_provider

        create :ecf_statement,
               name: "November 2021",
               cpd_lead_provider: cpd_lead_provider,
               deadline_date: Date.new(2021, 11, 25)

        create :ecf_statement,
               cpd_lead_provider: cpd_lead_provider,
               deadline_date: 10.days.from_now

        token = LeadProviderApiToken.create_with_random_token! cpd_lead_provider: cpd_lead_provider,
                                                               lead_provider: lead_provider,
                                                               private_api_access: true

        tokens[lead_provider_name] = token

        travel_to 1.minute.from_now
      end
    end

    def and_sit_at_pupil_premium_school_reported_programme(sit_name, programme)
      next_ideal_time Time.zone.local(2021, 4, 1, 9, 0, 0)

      travel_to(@timestamp) do
        school = create :school, :pupil_premium_uplift, name: "#{sit_name}'s School"
        user = create :user, full_name: sit_name
        create :induction_coordinator_profile,
               schools: [school],
               user: user
        privacy_policy.accept! user

        sign_in_as user
        choose_programme_wizard = Pages::SITReportProgrammeWizard.new
        choose_programme_wizard.complete(programme)
        sign_out

        if programme == "CIP"
          school_cohort = school.school_cohorts.first
          Induction::SetCohortInductionProgramme.call school_cohort: school_cohort,
                                                      programme_choice: school_cohort.induction_programme_choice
        end

        travel_to 1.minute.from_now
      end
    end

    def and_lead_provider_reported_partnership(lead_provider_name, sit_name)
      next_ideal_time Time.zone.local(2021, 5, 1, 9, 0, 0)

      user = find_user lead_provider_name
      lead_provider = user.lead_provider
      delivery_partner = lead_provider.delivery_partners.first

      school = find_school_for_sit sit_name

      travel_to(@timestamp) do
        sign_in_as user
        dashboard = Pages::LeadProviderDashboard.new
        wizard = dashboard.start_confirm_your_schools_wizard
        wizard.complete delivery_partner.name, [school.urn]
        sign_out

        # TODO: This needs to be added to the partnership UI process
        school_cohort = school.school_cohorts.first
        Induction::SetCohortInductionProgramme.call school_cohort: school_cohort,
                                                    programme_choice: school_cohort.induction_programme_choice

        travel_to 1.minute.from_now
      end
    end

    def and_sit_reported_participant(sit_name, participant_name, participant_email, participant_type)
      next_ideal_time Time.zone.local(2021, 6, 1, 9, 0, 0)

      user = find_user sit_name

      cohort_label = "Spring 2022"

      travel_to(@timestamp) do
        sign_in_as user
        inductions_dashboard = Pages::SchoolPage.new
        wizard = inductions_dashboard.start_add_participant_wizard
        wizard.complete(participant_name, participant_email, participant_type, cohort_label)
        sign_out

        travel_to 1.minute.from_now
      end
    end

    def and_participant_has_completed_registration(participant_name, participant_trn, participant_dob, participant_type)
      next_ideal_time Time.zone.local(2021, 8, 1, 9, 0, 0)

      user = find_user participant_name

      travel_to(@timestamp) do
        sign_in_as user
        wizard = Pages::ParticipantRegistrationWizard.new
        case participant_type
        when "ECT"
          wizard.complete_for_ect participant_name, participant_dob, participant_trn
        when "Mentor"
          wizard.complete_for_mentor participant_name, participant_dob, participant_trn
        else
          raise "Participant_type not recognised"
        end
        sign_out

        travel_to 1.minute.from_now
      end
    end

    def and_lead_provider_has_made_training_declaration(lead_provider_name, participant_type, participant_name, declaration_type)
      participant_profile = find_participant_profile participant_name

      course_identifier = participant_type == "ECT" ? "ecf-induction" : "ecf-mentor"

      case declaration_type
      when :started
        next_ideal_time participant_profile.schedule.milestones.first.start_date + 4.days
      when :retained_1
        next_ideal_time participant_profile.schedule.milestones.second.start_date + 4.days
      else
        raise "declaration type was #{declaration_type} but expected [started, retained_1]"
      end

      travel_to(@timestamp) do
        declarations_endpoint = APIs::PostParticipantDeclarationsEndpoint.new tokens[lead_provider_name]
        declarations_endpoint.post_training_declaration participant_profile.user.id, course_identifier, declaration_type, @timestamp - 2.days

        declarations_endpoint.has_declaration_type? declaration_type.to_s
        declarations_endpoint.has_eligible_for_payment? true
        declarations_endpoint.has_voided? false
        declarations_endpoint.has_state? "eligible"

        travel_to 1.minute.from_now
      end
    end

    def and_lead_provider_withdraws_participant(lead_provider_name, participant_name, participant_type)
      participant_profile = find_participant_profile participant_name

      course_identifier = participant_type == "ECT" ? "ecf-induction" : "ecf-mentor"

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 2.days
      travel_to(@timestamp) do
        withdraw_endpoint = APIs::ParticipantWithdrawEndpoint.new tokens[lead_provider_name]
        withdraw_endpoint.post_withdraw_notice participant_profile.user.id, course_identifier, "moved-school"

        withdraw_endpoint.responded_with_full_name? participant_name
        withdraw_endpoint.responded_with_obfuscated_email?
        withdraw_endpoint.responded_with_status? "active"
        withdraw_endpoint.responded_with_training_status? "withdrawn"

        travel_to 1.minute.from_now
      end
    end

    def and_lead_provider_defers_participant(lead_provider_name, participant_name, participant_email, participant_type)
      participant_profile = find_participant_profile participant_name

      course_identifier = participant_type == "ECT" ? "ecf-induction" : "ecf-mentor"

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 2.days
      travel_to(@timestamp) do
        defer_endpoint = APIs::ParticipantDeferEndpoint.new tokens[lead_provider_name]
        defer_endpoint.post_defer_notice participant_profile.user.id, course_identifier, "career-break"

        defer_endpoint.responded_with_full_name? participant_name
        defer_endpoint.responded_with_email? participant_email
        defer_endpoint.responded_with_status? "active"
        defer_endpoint.responded_with_training_status? "deferred"

        travel_to 1.minute.from_now
      end
    end

    def and_school_withdraws_participant(_sit_name, participant_name)
      # TODO: This needs to be automated through the inductions portal

      participant_profile = find_participant_profile participant_name

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 2.days
      travel_to(@timestamp) do
        # OLD way
        participant_profile.withdrawn_record!

        # NEW way
        current_induction_record = participant_profile.current_induction_records.first
        current_induction_record.withdrawing! unless current_induction_record.nil?

        travel_to 1.minute.from_now
      end
    end

    def when_school_takes_on_the_active_participant(sit_name, participant_name, participant_email, participant_trn, participant_dob, circumstance, same_provider)
      user = find_user sit_name

      school = find_school_for_sit sit_name
      school_cohort = school.school_cohorts.first

      participant_profile = find_participant_profile participant_name

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 3.days
      travel_to(@timestamp) do
        if circumstance == "FIP>FIP"
          sign_in_as user
          inductions_dashboard = Pages::SchoolPage.new
          wizard = inductions_dashboard.start_transfer_participant_wizard
          wizard.complete(participant_name, participant_email, participant_trn, participant_dob, same_provider == :same_provider)
          sign_out
        else
          # OLD way
          participant_profile.teacher_profile.update! school: school
          participant_profile.active_record!
          participant_profile.training_status_active!
          participant_profile.update! school_cohort: school_cohort

          # NEW way
          current_induction_record = participant_profile.current_induction_records.first
          current_induction_record.withdrawing! unless current_induction_record.nil?

          Induction::Enrol.call participant_profile: participant_profile,
                                induction_programme: school_cohort.default_induction_programme,
                                start_date: @timestamp
        end

        travel_to 1.minute.from_now
      end
    end

    def when_school_takes_on_the_withdrawn_participant(sit_name, participant_name, _participant_email, _participant_trn, _participant_dob, _circumstance, _same_provider)
      school = find_school_for_sit sit_name
      school_cohort = school.school_cohorts.first

      participant_profile = find_participant_profile participant_name

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 3.days
      travel_to(@timestamp) do
        # OLD way
        participant_profile.teacher_profile.update! school: school
        participant_profile.active_record!
        participant_profile.training_status_active!
        participant_profile.update! school_cohort: school_cohort

        profile_state = participant_profile.participant_profile_state
        profile_state.delete
        participant_profile.reload

        # NEW way
        current_induction_record = participant_profile.current_induction_records.first
        current_induction_record.withdrawing! unless current_induction_record.nil?

        Induction::Enrol.call participant_profile: participant_profile,
                              induction_programme: school_cohort.default_induction_programme,
                              start_date: @timestamp

        travel_to 1.minute.from_now
      end
    end

    def when_school_takes_on_the_deferred_participant(sit_name, participant_name, _participant_email, _participant_trn, _participant_dob, _circumstance, _same_provider)
      school = find_school_for_sit sit_name
      school_cohort = school.school_cohorts.first

      participant_profile = find_participant_profile participant_name

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 3.days
      travel_to(@timestamp) do
        # OLD way
        participant_profile.teacher_profile.update! school: school
        participant_profile.active_record!
        participant_profile.training_status_active!
        participant_profile.update! school_cohort: school_cohort

        profile_state = participant_profile.participant_profile_state
        profile_state.delete
        participant_profile.reload

        # NEW way
        current_induction_record = participant_profile.current_induction_records.first
        current_induction_record.withdrawing! unless current_induction_record.nil?

        Induction::Enrol.call participant_profile: participant_profile,
                              induction_programme: school_cohort.default_induction_programme,
                              start_date: @timestamp

        travel_to 1.minute.from_now
      end
    end

    def and_eligible_training_declarations_are_made_payable
      ParticipantDeclaration.eligible.each do |participant_declaration|
        participant_declaration.make_payable!
        participant_declaration.update! statement: participant_declaration.cpd_lead_provider.statements.first
      end
    end

    def and_lead_provider_statements_have_been_created(lead_provider_name)
      lead_provider = find_lead_provider lead_provider_name

      nov_statement = lead_provider.cpd_lead_provider.statements.first

      Finance::ECF::CalculationOrchestrator.new(
        statement: nov_statement,
        contract: lead_provider.call_off_contract,
        aggregator: Finance::ECF::ParticipantAggregator.new(statement: nov_statement),
        calculator: PaymentCalculator::ECF::PaymentCalculation,
      ).call(event_type: :started)
    end

  private

    def next_ideal_time(ideal)
      if !@timestamp || ideal > @timestamp
        @timestamp = ideal
      else
        @timestamp += 1.minute
      end
    end

    def find_user(full_name)
      user = User.find_by(full_name: full_name)
      raise "Could not find User for #{full_name}" if user.nil?

      user
    end

    def find_participant_profile(participant_name)
      user = find_user participant_name

      participant_profile = user.participant_profiles.first
      raise "Could not find ParticipantProfile for #{participant_name}" if participant_profile.nil?

      participant_profile
    end

    def find_school_induction_tutor(sit_name)
      user = find_user sit_name

      sit = user.induction_coordinator_profile
      raise "Could not find User for #{sit_name}" if sit.nil?

      sit
    end

    def find_school_for_sit(sit_name)
      sit = find_school_induction_tutor sit_name

      school = sit.schools.first
      raise "Could not find School for #{sit_name}" if school.nil?

      school
    end

    def find_lead_provider(lead_provider_name)
      user = find_user lead_provider_name

      lead_provider = user.lead_provider
      raise "Could not find Lead Provider for #{lead_provider}" if lead_provider.nil?

      lead_provider
    end
  end
end
