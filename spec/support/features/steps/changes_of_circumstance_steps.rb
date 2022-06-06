# frozen_string_literal: true

module Steps
  module ChangesOfCircumstanceSteps
    include RSpec::Matchers

    def given_lead_providers_contracted_to_deliver_ecf(lead_provider_name)
      next_ideal_time Time.zone.local(2022, 2, 1, 9, 0, 0)
      travel_to(@timestamp) do
        lead_provider = create(:lead_provider, name: lead_provider_name)
        cpd_lead_provider = create(:cpd_lead_provider, lead_provider:, name: lead_provider_name)
        create :call_off_contract, lead_provider: lead_provider

        delivery_partner = create(:delivery_partner, name: "#{lead_provider_name}'s Delivery Partner 2021")
        create :provider_relationship, lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: Cohort.find_by(start_year: 2021)
        delivery_partner = create(:delivery_partner, name: "#{lead_provider_name}'s Delivery Partner 2022")
        create :provider_relationship, lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: Cohort.find_by(start_year: 2021)

        user = create(:user, full_name: lead_provider_name)
        create :lead_provider_profile, user: user, lead_provider: lead_provider

        tokens[lead_provider_name] = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:, lead_provider:, private_api_access: true)

        travel_to 1.minute.from_now
      end
    end

    def and_sit_at_pupil_premium_school_reported_programme(sit_name, programme)
      next_ideal_time Time.zone.local(2022, 4, 1, 9, 0, 0)
      travel_to(@timestamp) do
        school = create(:school, :pupil_premium_uplift, name: "#{sit_name}'s School")
        user = create(:user, full_name: sit_name)
        create :induction_coordinator_profile, schools: [school], user: user
        PrivacyPolicy.current.accept! user

        sign_in_as user
        Pages::SchoolReportProgrammeWizard.loaded
                                          .complete(programme)

        if programme == "CIP"
          school_cohort = school.school_cohorts.where(cohort: Cohort.find_by_start_year(2021)).first
          Induction::SetCohortInductionProgramme.call school_cohort:,
                                                      programme_choice: school_cohort.induction_programme_choice
        end
        sign_out

        travel_to 1.minute.from_now
      end
    end

    def and_lead_provider_reported_partnership(lead_provider_name, sit_name)
      delivery_partner = DeliveryPartner.find_by(name: "#{lead_provider_name}'s Delivery Partner 2022")

      school = find_school_for_sit(sit_name)

      next_ideal_time Time.zone.local(2022, 5, 1, 9, 0, 0)
      travel_to(@timestamp) do
        given_i_sign_in_as_the_user_with_the_full_name lead_provider_name

        Pages::LeadProviderDashboard.loaded
                                    .confirm_schools
                                    .complete delivery_partner.name, [school.urn]
        sign_out

        travel_to 1.minute.from_now
      end
    end

    def and_sit_reported_participant(sit_name, participant_name, participant_email, participant_type)
      next_ideal_time Time.zone.local(2022, 6, 1, 9, 0, 0)
      travel_to(@timestamp) do
        given_i_sign_in_as_the_user_with_the_full_name sit_name

        wizard = Pages::SchoolDashboardPage.loaded
                                           .add_participant_details
                                           .continue
                                           .choose_to_add_an_ect_or_mentor

        if participant_type == "ECT"
          wizard.add_ect participant_name, participant_email, Date.new(2022, 9, 1)
        else
          wizard.add_mentor participant_name, participant_email
        end
        sign_out

        travel_to 1.minute.from_now
      end
    end

    def and_participant_has_completed_registration(participant_name, participant_trn, participant_dob, participant_type)
      next_ideal_time Time.zone.local(2022, 9, 2, 9, 0, 0)
      travel_to(@timestamp) do
        given_i_sign_in_as_the_user_with_the_full_name participant_name

        case participant_type
        when "ECT"
          Pages::PrivacyPolicyPage.loaded
                                  .continue_for_ect
                                  .complete participant_name, participant_dob, participant_trn
        when "Mentor"
          Pages::PrivacyPolicyPage.loaded
                                  .continue_for_mentor
                                  .complete participant_name, participant_dob, participant_trn
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
      milestone = participant_profile.schedule.milestones
                                     .where(declaration_type: declaration_type.to_s.gsub("_", "-"))
                                     .first

      next_ideal_time milestone.milestone_date - 2.days
      travel_to(@timestamp) do
        event_date = milestone.milestone_date - 4.days
        declarations_endpoint = APIs::PostParticipantDeclarationsEndpoint.new tokens[lead_provider_name]
        declarations_endpoint.post_training_declaration participant_profile.user.id, course_identifier, declaration_type, event_date

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

    def and_developer_withdraws_participant(participant_name)
      participant_profile = find_participant_profile participant_name

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 2.days
      travel_to(@timestamp) do
        # OLD way
        participant_profile.withdrawn_record!

        # NEW way
        current_induction_record = participant_profile.current_induction_records.first
        current_induction_record.withdrawing! unless current_induction_record.nil?

        travel_to 2.days.from_now
      end
    end

    def when_school_uses_the_transfer_participant_wizard(sit_name, participant_name, participant_email, participant_trn, participant_dob, same_provider: false)
      participant_profile = find_participant_profile participant_name

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 3.days
      travel_to(@timestamp) do
        given_i_sign_in_as_the_user_with_the_full_name sit_name

        page_object = Pages::SchoolDashboardPage.loaded
                                                .add_participant_details
                                                .continue
                                                .choose_to_transfer_an_ect_or_mentor

        if participant_profile.ect?
          page_object.transfer_ect participant_name, participant_email, 1.day.from_now, same_provider, participant_trn, participant_dob
        else
          page_object.transfer_mentor participant_name, participant_email, 1.day.from_now, same_provider, participant_trn, participant_dob
        end

        sign_out

        travel_to 2.days.from_now
      end
    end

    def when_developers_transfer_the_active_participant(sit_name, participant_name)
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

        # NEW way
        current_induction_record = participant_profile.current_induction_records.current.first
        current_induction_record.changing! unless current_induction_record.nil?

        Induction::Enrol.call participant_profile: participant_profile,
                              induction_programme: school_cohort.default_induction_programme,
                              start_date: 1.day.from_now

        travel_to 2.days.from_now
      end
    end

    def when_developers_transfer_the_withdrawn_participant(sit_name, participant_name)
      school = find_school_for_sit sit_name
      school_cohort = school.school_cohorts.first

      participant_profile = find_participant_profile participant_name

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 3.days
      travel_to(@timestamp) do
        # OLD way
        profile_state = participant_profile.participant_profile_state
        profile_state.delete
        participant_profile.reload

        participant_profile.teacher_profile.update! school: school
        participant_profile.active_record!
        participant_profile.training_status_active!
        participant_profile.update! school_cohort: school_cohort

        # NEW way
        current_induction_record = participant_profile.current_induction_records.current.first
        current_induction_record.changing! unless current_induction_record.nil?

        Induction::Enrol.call participant_profile: participant_profile,
                              induction_programme: school_cohort.default_induction_programme,
                              start_date: 1.day.from_now

        travel_to 2.days.from_now
      end
    end

    def when_developers_transfer_the_deferred_participant(sit_name, participant_name)
      school = find_school_for_sit sit_name
      school_cohort = school.school_cohorts.first

      participant_profile = find_participant_profile participant_name

      next_ideal_time participant_profile.schedule.milestones.first.start_date + 3.days
      travel_to(@timestamp) do
        # OLD way
        profile_state = participant_profile.participant_profile_state
        profile_state.delete
        participant_profile.reload

        participant_profile.teacher_profile.update! school: school
        participant_profile.active_record!
        participant_profile.training_status_active!
        participant_profile.update! school_cohort: school_cohort

        # NEW way
        current_induction_record = participant_profile.current_induction_records.current.first
        current_induction_record.changing! unless current_induction_record.nil?

        Induction::Enrol.call participant_profile: participant_profile,
                              induction_programme: school_cohort.default_induction_programme,
                              start_date: 1.day.from_now

        travel_to 2.days.from_now
      end
    end

    def and_eligible_training_declarations_are_made_payable(statement_name)
      next_ideal_time @timestamp + 3.days
      travel_to(@timestamp) do
        ParticipantDeclaration.eligible.each do |participant_declaration|
          participant_declaration.make_payable!
          statement = Finance::Statement::ECF.find_by!(name: statement_name, cpd_lead_provider: participant_declaration.cpd_lead_provider)
          participant_declaration.update! statement:
        end
      end
    end

    def then_sit_cannot_see_participant_in_school_portal(sit_name)
      given_i_sign_in_as_the_user_with_the_full_name sit_name

      then_i_confirm_has_no_participants_on_the_school_dashboard_page

      sign_out
    end

    def then_sit_can_see_participant_in_school_portal(sit_name, scenario)
      given_i_sign_in_as_the_user_with_the_full_name sit_name

      when_i_view_participant_details_from_the_school_dashboard_page
      case scenario.participant_type
      when "ECT"
        and_i_view_ects_from_the_school_participants_dashboard_page "the Participant"
      when "Mentor"
        and_i_view_mentors_from_the_school_participants_dashboard_page "the Participant"
      else
        raise "Participant Type \"#{scenario.participant_type}\" not recognised"
      end

      then_i_confirm_participant_name_on_the_school_participant_details_page "the Participant"
      then_i_confirm_full_name_on_the_school_participant_details_page "the Participant"
      then_i_confirm_email_address_on_the_school_participant_details_page scenario.participant_email
      then_i_confirm_status_on_the_school_participant_details_page "Eligible to start"

      sign_out
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
      user = User.find_by(full_name:)
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
