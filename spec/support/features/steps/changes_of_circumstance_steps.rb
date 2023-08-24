# frozen_string_literal: true

module Steps
  # noinspection RubyTooManyMethodsInspection
  module ChangesOfCircumstanceSteps
    include RSpec::Matchers

    def given_lead_providers_contracted_to_deliver_ecf(lead_provider_name)
      next_ideal_time Time.zone.local(2021, 2, 1, 9, 0, 0)
      travel_to(@timestamp) do
        lead_provider = create(:lead_provider, name: lead_provider_name)
        cpd_lead_provider = create(:cpd_lead_provider, lead_provider:, name: lead_provider_name)
        create(:call_off_contract, lead_provider:)

        delivery_partner = create(:delivery_partner, name: "#{lead_provider_name}'s Delivery Partner 2021")
        create :provider_relationship, lead_provider:, delivery_partner:, cohort: Cohort.find_by(start_year: 2021)

        user = create(:user, full_name: lead_provider_name)
        create(:lead_provider_profile, user:, lead_provider:)

        tokens[lead_provider_name] = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:, lead_provider:, private_api_access: true)

        travel_to 1.minute.from_now
      end
    end

    def and_sit_at_pupil_premium_school_reported_programme(sit_name, programme)
      next_ideal_time Time.zone.local(2021, 4, 1, 9, 0, 0)
      travel_to(@timestamp) do
        school = create(:school, :pupil_premium_uplift, name: "#{sit_name}'s School")
        user = create(:user, full_name: sit_name)
        create(:induction_coordinator_profile, schools: [school], user:)
        PrivacyPolicy.current.accept! user

        sign_in_as user
        Pages::SchoolReportProgrammeWizard.loaded
                                          .complete(programme)
        sign_out

        if programme == "CIP"
          school_cohort = school.school_cohorts.where(cohort: Cohort.find_by(start_year: 2021)).first
          Induction::SetCohortInductionProgramme.call school_cohort:, programme_choice: school_cohort&.induction_programme_choice
        end

        travel_to 1.minute.from_now
      end
    end

    def and_lead_provider_reported_partnership(lead_provider_name, sit_name)
      delivery_partner = DeliveryPartner.find_by(name: "#{lead_provider_name}'s Delivery Partner 2021")
      school = find_school_for_sit(sit_name)

      next_ideal_time Time.zone.local(2021, 5, 1, 9, 0, 0)
      travel_to(@timestamp) do
        given_i_sign_in_as_the_user_with_the_full_name lead_provider_name

        Pages::LeadProviderDashboard.loaded
                                    .confirm_schools
                                    .complete(delivery_partner.name, [school&.urn])
        sign_out

        travel_to 1.minute.from_now
      end
    end

    def and_sit_reported_participant(sit_name, participant_name, participant_trn, participant_dob, participant_email, participant_type)
      next_ideal_time Time.zone.local(2021, 6, 1, 9, 0, 0)
      travel_to(@timestamp) do
        given_i_sign_in_as_the_user_with_the_full_name sit_name

        wizard = Pages::SchoolDashboardPage.loaded
                                           .add_participant_details
                                           .choose_to_add_an_ect_or_mentor
        participant_start_date = Date.new(2021, 9, 1)

        allow(DQTRecordCheck).to receive(:call).and_return(
          DQTRecordCheck::CheckResult.new(
            {
              "name" => participant_name,
              "trn" => participant_trn,
              "state_name" => "Active",
              "dob" => participant_dob,
              "qualified_teacher_status" => { "qts_date" => 1.year.ago },
              "induction" => {
                "start_date" => 1.month.ago,
                "status" => "Active",
              },
            },
            true,
            true,
            true,
            false,
            3,
          ),
        )

        response = {
          trn: participant_trn,
          qts: true,
          active_alert: false,
          previous_participation: false,
          previous_induction: false,
          no_induction: false,
          exempt_from_induction: false,
        }
        allow(ParticipantValidationService).to receive(:validate).and_return(response)

        if participant_type == "ECT"
          wizard.add_ect participant_name, participant_trn, participant_dob, participant_email, participant_start_date
        else
          wizard.add_mentor participant_name, participant_trn, participant_dob, participant_email
        end
        sign_out

        travel_to 1.minute.from_now
      end
    end

    def and_lead_provider_has_made_training_declaration(lead_provider_name, participant_type, participant_name, declaration_type)
      participant_profile = find_participant_profile(participant_name)

      course_identifier = participant_type == "ECT" ? "ecf-induction" : "ecf-mentor"
      milestone = participant_profile.schedule.milestones
                                     .where(declaration_type: declaration_type.to_s.gsub("_", "-"))
                                     .first
      before_milestone_timestamp = milestone.milestone_date - 2.months
      next_ideal_time before_milestone_timestamp
      travel_to(@timestamp) do
        event_date = before_milestone_timestamp - 4.days
        declarations_endpoint = APIs::PostParticipantDeclarationsEndpoint.load(tokens[lead_provider_name])
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
        withdraw_endpoint = APIs::ParticipantWithdrawEndpoint.load(tokens[lead_provider_name])
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
        defer_endpoint = APIs::ParticipantDeferEndpoint.load(tokens[lead_provider_name])
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
                                                .choose_to_add_an_ect_or_mentor

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
        participant_profile.teacher_profile.update!(school:)
        participant_profile.active_record!
        participant_profile.training_status_active!
        participant_profile.update!(school_cohort:)

        # NEW way
        current_induction_record = participant_profile.current_induction_records.current.first
        current_induction_record.changing! unless current_induction_record.nil?

        Induction::Enrol.call participant_profile:,
                              induction_programme: school_cohort.default_induction_programme,
                              start_date: 1.day.from_now
        if participant_profile.mentor?
          if current_induction_record
            Mentors::ChangeSchool.call(from_school: participant_profile.current_induction_record.school,
                                       to_school: school,
                                       mentor_profile: participant_profile,
                                       remove_on_date: 1.day.from_now,
                                       preferred_email: participant_profile.participant_identity.email)
          else
            Mentors::AddToSchool.call(mentor_profile: participant_profile, school:)
          end
        end

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

        participant_profile.teacher_profile.update!(school:)
        participant_profile.active_record!
        participant_profile.training_status_active!
        participant_profile.update!(school_cohort:)

        # NEW way
        current_induction_record = participant_profile.current_induction_records.current.first
        current_induction_record.changing! unless current_induction_record.nil?

        Induction::Enrol.call participant_profile:,
                              induction_programme: school_cohort.default_induction_programme,
                              start_date: 1.day.from_now
        if participant_profile.mentor?
          if current_induction_record
            Mentors::ChangeSchool.call(from_school: participant_profile.current_induction_record.school,
                                       to_school: school,
                                       mentor_profile: participant_profile,
                                       remove_on_date: 1.day.from_now,
                                       preferred_email: participant_profile.participant_identity.email)
          else
            Mentors::AddToSchool.call(mentor_profile: participant_profile, school:)
          end
        end

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

        participant_profile.teacher_profile.update!(school:)
        participant_profile.active_record!
        participant_profile.training_status_active!
        participant_profile.update!(school_cohort:)

        # NEW way
        current_induction_record = participant_profile.current_induction_records.current.first
        current_induction_record.changing! unless current_induction_record.nil?

        Induction::Enrol.call participant_profile:,
                              induction_programme: school_cohort.default_induction_programme,
                              start_date: 1.day.from_now
        if participant_profile.mentor?
          if current_induction_record
            Mentors::ChangeSchool.call(from_school: participant_profile.current_induction_record.school,
                                       to_school: school,
                                       mentor_profile: participant_profile,
                                       remove_on_date: 1.day.from_now,
                                       preferred_email: participant_profile.participant_identity.email)
          else
            Mentors::AddToSchool.call(mentor_profile: participant_profile, school:)
          end
        end

        travel_to 2.days.from_now
      end
    end

    def and_eligible_training_declarations_are_made_payable
      next_ideal_time @timestamp + 3.days
      travel_to(@timestamp) do
        ParticipantDeclaration.eligible.each(&:make_payable!)
      end
    end

    def self.then_sit_cannot_see_context(scenario)
      "cannot see \"The Participant\" as a \"#{scenario.participant_type}\"\n"
    end

    def then_sit_cannot_see_participant_in_school_portal(sit_name, _scenario = {})
      given_i_sign_in_as_the_user_with_the_full_name sit_name

      school_dashboard_page = Pages::SchoolDashboardPage.loaded
      school_dashboard_page.confirm_has_no_participants

      sign_out
    end

    def self.then_sit_can_see_context(scenario, is_training: true)
      str = "can see \"The Participant\" as a \"#{scenario.participant_type}\"\n"
      str += "          with the Email address of \"#{scenario.participant_email}\"\n"
      str += "          and that they are#{is_training ? '' : ' not'} being trained\n"
      str
    end

    def then_sit_can_see_participant_in_school_portal(sit_name, scenario)
      given_i_sign_in_as_the_user_with_the_full_name sit_name

      school_dashboard = Pages::SchoolDashboardPage.loaded
      participant_dashboard = school_dashboard.view_participant_dashboard

      participant_details = participant_dashboard.view_participant("The Participant")
      expect(participant_details).to have_participant_name "The Participant"
      expect(participant_details).to have_email scenario.participant_email
      expect(participant_details).to have_full_name "The Participant"

      sign_out
    end

    def then_sit_can_see_not_training_in_school_portal(sit_name, scenario)
      given_i_sign_in_as_the_user_with_the_full_name sit_name

      school_dashboard = Pages::SchoolDashboardPage.loaded
      participant_dashboard = school_dashboard.view_participant_dashboard

      participant_details = participant_dashboard.view_participant("The Participant")
      expect(participant_details).to have_participant_name "The Participant"
      expect(participant_details).to have_email scenario.participant_email
      expect(participant_details).to have_full_name "The Participant"

      sign_out
    end

    def self.then_lead_provider_cannot_see_context(scenario)
      "cannot see \"The Participant\" as a \"#{scenario.participant_type}\"\n"
    end

    def then_lead_provider_cannot_see_participant_in_api(lead_provider_name, _scenario)
      then_ecf_participants_api_does_not_have_participant_details lead_provider_name,
                                                                  "The Participant"

      then_participant_declarations_api_does_not_have_declarations lead_provider_name,
                                                                   "The Participant"
    end

    def self.then_lead_provider_can_see_context(scenario, declarations, participant_status = "active", see_prior_school: false)
      school_name = see_prior_school ? "Original SIT's School" : "New SIT's School"
      str = "can see \"The Participant\" as a \"#{scenario.participant_type}\"\n"
      str += "          with the participant email as \"#{scenario.participant_email}\"\n"
      str += "          and with the participant trn as \"#{scenario.participant_trn}\"\n"
      str += "          and with the participant status of \"#{participant_status}\"\n"
      str += "          and with the participants school as \"#{school_name}\"\n"
      str += "          and with the participants declarations #{declarations}\n"
      str
    end

    def then_lead_provider_can_see_participant_in_api(lead_provider_name, scenario, declarations, participant_status = "active", see_prior_school: false)
      then_ecf_participants_api_has_participant_details lead_provider_name,
                                                        "The Participant",
                                                        scenario.participant_email,
                                                        scenario.participant_trn,
                                                        scenario.participant_type,
                                                        see_prior_school ? "Original SIT's School" : "New SIT's School",
                                                        participant_status,
                                                        "active"

      then_participant_declarations_api_has_declarations lead_provider_name,
                                                         "The Participant",
                                                         declarations
    end

    def then_ecf_participants_api_does_not_have_participant_details(lead_provider_name, participant_name)
      user = User.find_by(full_name: participant_name)

      declarations_endpoint = APIs::V1::ECFParticipantsEndpoint.load tokens[lead_provider_name]
      expect { declarations_endpoint.get_participant(user.id) }.to raise_error(Capybara::ElementNotFound)
    end

    def then_ecf_participants_api_has_participant_details(lead_provider_name, participant_name, participant_email, participant_trn, participant_type, school_name, participant_status, training_status)
      user = User.find_by(full_name: participant_name)
      school = School.find_by(name: school_name)

      endpoint = APIs::V1::ECFParticipantsEndpoint.load(tokens[lead_provider_name])
      endpoint.get_participant user.id

      endpoint.has_full_name? participant_name
      endpoint.has_email_address? participant_email
      endpoint.has_trn? participant_trn
      endpoint.has_school_urn? school.urn
      endpoint.has_participant_type? participant_type.to_s.downcase

      endpoint.has_status? participant_status
      endpoint.has_training_status? training_status
    end

    def then_participant_declarations_api_has_declarations(lead_provider_name, participant_name, declarations = [])
      user = User.find_by(full_name: participant_name)

      endpoint = APIs::GetParticipantDeclarationsEndpoint.load(tokens[lead_provider_name])
      endpoint.get_training_declarations user.id

      expect(endpoint).to have_declarations(declarations)
    end

    def then_participant_declarations_api_does_not_have_declarations(lead_provider_name, participant_name)
      user = User.find_by(full_name: participant_name)

      endpoint = APIs::GetParticipantDeclarationsEndpoint.load tokens[lead_provider_name]
      endpoint.get_training_declarations user.id

      endpoint.has_declarations? []
    end

    def self.then_finance_user_context(scenario)
      str = "can see \"The Participant\" as a \"#{scenario.participant_type}\"\n"
      str += "          with the school as \"New SIT's school\"\n"
      str += "          and with the lead provider as \"#{scenario.new_lead_provider_name}\"\n"
      str += "          and with the participant status as \"active\"\n"
      str += "          and with the training status as \"active\"\n"
      str += "          and with the declarations of \"#{scenario.see_new_declarations}\"\n"
      if scenario.original_programme == "FIP"
        str += "          and that Original Lead Provider has been allocated #{scenario.original_started_declarations} started and #{scenario.original_retained_declarations} retained declarations\n"
      end
      if scenario.new_programme == "FIP" && scenario.transfer != :same_provider
        str += "          and that New Lead Provider has been allocated #{scenario.new_started_declarations} started and #{scenario.new_retained_declarations} retained declarations\n"
      end
      str += "          and that Other Lead Providers have been allocated 0 started and 0 retained declarations\n"
      str
    end

    def then_the_finance_portal_shows_the_current_participant_record(participant_name, participant_type, sit_name, lead_provider_name, participant_status, training_status, declarations = [])
      participant_user = find_user participant_name
      school = find_school_for_sit sit_name

      course_identifier = participant_type == "ECT" ? "ecf-induction" : "ecf-mentor"

      finance_portal = Pages::FinancePortal.load

      drilldown_search = finance_portal.view_participant_drilldown
      drilldown = drilldown_search.find participant_name

      drilldown.has_participant_id? participant_user.id
      drilldown.has_school_urn? school.urn
      drilldown.has_lead_provider? lead_provider_name
      drilldown.has_status? participant_status
      drilldown.has_training_status? training_status

      declarations.each do |declaration_type|
        drilldown.has_declaration? declaration_type, course_identifier, "payable"
      end
    end

    def then_the_finance_portal_shows_the_lead_provider_payment_breakdown(lead_provider_name, statement_name, total_ects, total_mentors, started, retained, completed, voided, uplift: true)
      allow(Finance::Statement::ECF).to receive(:current).and_return(Finance::Statement::ECF.find_by(cohort: Cohort.current, cpd_lead_provider: CpdLeadProvider.find_by(name: lead_provider_name), name: statement_name))

      finance_portal = Pages::FinancePortal.load

      report_wizard = finance_portal.view_payment_breakdown

      statement = report_wizard.complete lead_provider_name
      statement.select_statement statement_name

      statement.has_started_declarations_total? started
      statement.has_retained_declarations_total? retained
      statement.has_completed_declarations_total? completed
      statement.has_voided_declarations_total? voided

      statement.has_started_declaration_payment_table? num_ects: total_ects, num_mentors: total_mentors, num_declarations: started
      statement.has_retained_1_declaration_payment_table? num_ects: total_ects, num_mentors: total_mentors, num_declarations: retained
      statement.has_other_fees_table? num_ects: uplift ? total_ects : 0, num_mentors: uplift ? total_mentors : 0
    end

    def self.then_admin_user_context(scenario)
      str = "can see \"The Participant\" as a \"#{scenario.participant_type}\"\n"
      str += "          with the school as \"New SIT's school\"\n"
      str += "          and with the lead provider as \"#{scenario.new_lead_provider_name}\""
      str
    end

    def then_admin_user_can_see_participant(scenario)
      given_i_sign_in_as_an_admin_user

      admin_support_portal = Pages::AdminSupportPortal.loaded
      participant_list = admin_support_portal.view_participant_list

      participant_detail = participant_list.view_participant "The Participant"

      # primary heading needs checking participant_name
      participant_detail.has_primary_heading? "The Participant"
      participant_detail.has_full_name? "The Participant"

      training_record_state = scenario.participant_type == "ECT" ? "Eligible to start" : "Not yet mentoring"
      participant_detail.has_training_record_state? training_record_state

      # now the school data is on a sibling page, we need to navigate
      # there before checking the school/lead provider contents
      participant_training = participant_detail.open_training_tab

      school = find_school_for_sit "New SIT"
      participant_training.has_school_name? school.name
      participant_training.has_lead_provider? scenario.new_lead_provider_name

      sign_out
    end

    def self.then_support_service_context(scenario)
      str = "can see \"The Participant\" as a \"#{scenario.participant_type}\"\n"
      str += "          with the email address as \"#{scenario.participant_email}\"\n"
      str += "          and with the induction programme as \"#{scenario.new_programme == 'CIP' ? 'core_induction_programme' : 'full_induction_programme'}\"\n"
      str
    end

    def then_ecf_users_endpoint_shows_the_current_record(scenario)
      participant_user = find_user "The Participant"

      participant_type = scenario.participant_type == "ECT" ? "early_career_teacher" : "mentor"
      induction_programme_identifier = scenario.new_programme == "CIP" ? "core_induction_programme" : "full_induction_programme"

      user_endpoint = APIs::ECFUsersEndpoint.load
      user_endpoint.get_user participant_user.id

      expect(user_endpoint).to have_full_name "The Participant"
      expect(user_endpoint).to have_email scenario.participant_email
      expect(user_endpoint).to have_user_type participant_type
      expect(user_endpoint).to have_core_induction_programme "none"
      expect(user_endpoint).to have_induction_programme_choice induction_programme_identifier
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

    # helper whilst debugging scenarios with --fail-fast

    def full_stop(html: false)
      links = page.all("main a").map { |link| "  -  #{link.text} href: #{link['href']}" }

      puts "==="
      puts page.current_url
      puts "---"
      if html
        puts page.html
      else
        puts page.find("main").text
      end
      puts "---\nLinks:"
      puts links
      puts "==="
      raise
    end
  end
end
