# frozen_string_literal: true

require "rails_helper"

RSpec.describe "transferring participants", :with_default_schedules, type: :feature, js: true, rutabaga: false do
  context "Transferring an ECT to a school" do
    context "ECT has matching lead provider and delivery partner" do
      before do
        allow_participant_transfer_mailers
        set_participant_data
        set_dqt_validation_result
        given_there_are_two_schools_that_have_chosen_fip_for_the_current_cohort_and_partnered
        and_there_is_an_ect_who_will_be_transferring
        and_i_am_signed_in_as_an_induction_coordinator
        and_i_have_selected_my_cohort_tab
        when_i_click_to_view_ects_and_mentors
        then_i_am_taken_to_manage_mentors_and_ects_page
      end

      scenario "Induction tutor can transfer an ECT to their school" do
        when_i_click_to_add_an_ect_or_mentor
        then_i_should_be_on_the_who_to_add_page
        then_the_page_should_be_accessible

        # when_i_select_transfer_teacher_option
        when_i_select_the_ect_option
        click_on "Continue"
        then_i_should_be_on_what_we_need_page
        then_the_page_should_be_accessible

        click_on "Continue"
        then_i_should_be_on_full_name_page
        then_the_page_should_be_accessible

        click_on "Continue"
        then_i_receive_a_missing_name_error_message

        when_i_update_the_name_with(@participant_data[:full_name])
        click_on "Continue"
        then_i_should_be_on_trn_page
        then_the_page_should_be_accessible

        click_on "Continue"
        then_i_should_see_a_enter_trn_error_message

        when_i_add_an_invalid_trn
        click_on "Continue"
        then_i_should_see_invalid_trn_message

        when_i_add_a_valid_trn
        click_on "Continue"
        then_i_should_be_on_the_date_of_birth_page
        then_the_page_should_be_accessible

        click_on "Continue"
        then_i_should_see_enter_date_of_birth_error_message

        when_i_add_an_invalid_date_of_birth
        click_on "Continue"
        then_i_should_see_invalid_date_of_birth_error_message

        when_i_add_a_valid_date_of_birth
        click_on "Continue"

        then_i_should_be_on_the_confirm_transfer_page
        then_the_page_should_be_accessible
        click_on "Confirm"

        then_i_should_be_on_the_teacher_start_date_page
        then_the_page_should_be_accessible

        click_on "Continue"
        then_i_should_see_enter_start_date_error_message
        when_i_add_an_invalid_start_date
        click_on "Continue"
        then_i_should_see_invalid_start_date_error_message

        when_i_add_a_date_prior_to_the_participants_induction_start
        click_on "Continue"
        then_i_should_see_start_date_must_be_after_error_message

        when_i_add_a_valid_start_date
        click_on "Continue"

        then_i_should_be_on_the_add_email_page
        then_the_page_should_be_accessible

        click_on "Continue"
        then_i_should_see_blank_email_date_error_message

        when_i_update_the_email_with("sally-teacher")
        click_on "Continue"
        then_i_should_see_invalid_email_date_error_message

        when_i_update_the_email_with("sally-teacher@example.com")
        click_on "Continue"
        then_i_should_be_on_the_select_mentor_page
        then_the_page_should_be_accessible
        and_it_should_list_the_schools_mentors

        click_on "Continue"
        then_i_should_see_select_option_error_message

        when_i_assign_a_mentor
        click_on "Continue"

        then_i_should_be_taken_to_the_check_your_answers_page
        then_the_page_should_be_accessible

        click_on "Confirm and add"
        then_i_should_be_on_the_complete_page
        then_the_page_should_be_accessible
        and_the_participant_should_be_notified_with(:participant_transfer_in_notification)
        and_the_schools_current_provider_is_notified_with(:provider_existing_school_transfer_notification)

        click_on "View your ECTs and mentors"
        then_i_am_taken_to_manage_mentors_and_ects_page

        # click_on "Moving school"
        # then_i_should_see_the_transferring_participant
      end

      # given

      def given_there_are_two_schools_that_have_chosen_fip_for_the_current_cohort_and_partnered
        @cohort = Cohort.current
        @school_one = create(:school, name: "Fip School 1")
        @school_two = create(:school, name: "Fip School 2")
        @school_cohort_one = create(:school_cohort, school: @school_one, cohort: @cohort, induction_programme_choice: "full_induction_programme")
        @school_cohort_two = create(:school_cohort, school: @school_two, cohort: @cohort, induction_programme_choice: "full_induction_programme")
        @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
        @lead_provider_profile = create(:lead_provider_profile, lead_provider: @lead_provider)
        @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
        @mentor = create(:mentor_participant_profile, schedule: create(:ecf_schedule, cohort: @cohort), user: create(:user, full_name: "Billy Mentor"), school_cohort: @school_cohort_one)
        @partnership_1 = create(:partnership, school: @school_one, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort)
        @partnership_2 = create(:partnership, school: @school_two, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort)
        @induction_programme_one = create(:induction_programme, :fip, school_cohort: @school_cohort_one, partnership: @partnership_1)
        @induction_programme_two = create(:induction_programme, :fip, school_cohort: @school_cohort_two, partnership: @partnership_2)
        @school_cohort_one.update!(default_induction_programme: @induction_programme_one)
        Induction::Enrol.call(participant_profile: @mentor, start_date: Date.new(Cohort.current.start_year, 9, 1), induction_programme: @induction_programme_one)
        Mentors::AddToSchool.call(school: @school_one, mentor_profile: @mentor)
      end

      # when

      def when_i_click_to_view_ects_and_mentors
        click_on("Manage mentors and ECTs")
      end

      def when_i_click_to_add_an_ect_or_mentor
        click_on "Add ECT or mentor"
      end

      def when_i_select_the_ect_option
        choose("ECT", allow_label_click: true)
      end

      def when_i_update_the_name_with(name)
        fill_in "What’s this ECT’s full name?", with: name
      end

      def when_i_update_the_email_with(email)
        fill_in "What’s #{@participant_data[:full_name]}’s email address?", with: email
      end

      def when_i_add_an_invalid_trn
        fill_in "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)", with: "1234"
      end

      def when_i_add_a_valid_trn
        fill_in "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)", with: "1001000"
      end

      def when_i_add_a_valid_date_of_birth
        legend = "What’s #{@participant_data[:full_name]}’s date of birth?"

        fill_in_date(legend, with: "1990-10-24")
      end

      def when_i_add_an_invalid_date_of_birth
        legend = "What’s #{@participant_data[:full_name]}’s date of birth?"

        fill_in_date(legend, with: "23-10-24")
      end

      def when_i_add_a_date_prior_to_the_participants_induction_start
        legend = "When is #{@participant_data[:full_name]} moving to your school?"

        fill_in_date(legend, with: "1998-10-24")
      end

      def when_i_add_an_invalid_start_date
        legend = "When is #{@participant_data[:full_name]} moving to your school?"

        fill_in_date(legend, with: "25-10-25")
      end

      def when_i_add_a_valid_start_date
        legend = "When is #{@participant_data[:full_name]} moving to your school?"

        fill_in_date(legend, with: "#{Cohort.current.start_year + 1}-10-24")
      end

      def when_i_assign_a_mentor
        choose(@mentor.user.full_name)
      end

      def when_i_select(option)
        choose(option)
      end

      # then

      def then_i_am_taken_to_manage_mentors_and_ects_page
        expect(page).to have_selector("h1", text: "Manage mentors and ECTs")
        expect(page).to have_text("Add ECT or mentor")
      end

      def then_i_should_be_on_what_we_need_page
        expect(page).to have_selector("h1", text: "What we need from you")
      end

      def then_i_should_be_on_full_name_page
        expect(page).to have_selector("h1", text: "What’s this ECT’s full name?")
      end

      def then_i_should_be_on_trn_page
        expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)")
      end

      def then_i_should_be_on_the_date_of_birth_page
        expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s date of birth")
      end

      def then_i_should_be_on_the_confirm_transfer_page
        expect(page).to have_selector("h1", text: "Confirm #{@participant_data[:full_name]} is moving from another school")
      end

      def then_i_should_be_on_the_teacher_start_date_page
        expect(page).to have_selector("h1", text: "When is #{@participant_data[:full_name]} moving to your school?")
      end

      def then_i_should_be_on_the_who_to_add_page
        expect(page).to have_selector("h1", text: "Who do you want to add?")
      end

      def then_i_should_be_on_the_add_email_page
        expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s email address?")
      end

      def then_i_should_be_on_the_select_mentor_page
        expect(page).to have_selector("h1", text: "Who will #{@participant_data[:full_name]}’s mentor be?")
      end

      def then_i_should_be_taken_to_the_check_your_answers_page
        expect(page).to have_selector("h1", text: "Check your answers")
        expect(page).to have_selector("dd", text: @mentor.user.full_name)
        expect(page).to have_selector("dd", text: @lead_provider.name)
        expect(page).to have_selector("dd", text: @delivery_partner.name)
      end

      def then_i_should_be_on_the_complete_page
        expect(page).to have_selector("h2", text: "What happens next")
        expect(page).to have_text("We’ll let this person know")
      end

      def then_i_receive_a_missing_name_error_message
        expect(page).to have_text("Enter a full name")
      end

      def then_i_should_see_a_enter_trn_error_message
        expect(page).to have_text("Enter the teacher reference number (TRN)")
      end

      def then_i_should_see_invalid_trn_message
        expect(page).to have_text("Teacher reference number must include at least 5 digits")
      end

      def then_i_should_see_enter_date_of_birth_error_message
        expect(page).to have_text("Enter a date of birth")
      end

      def then_i_should_see_invalid_date_of_birth_error_message
        expect(page).to have_text("Enter a valid date of birth")
      end

      def then_i_should_see_enter_start_date_error_message
        expect(page).to have_text("Enter the teacher’s joining date")
      end

      def then_i_should_see_invalid_start_date_error_message
        expect(page).to have_text("Enter a valid joining date")
      end

      def then_i_should_see_start_date_must_be_after_error_message
        expect(page).to have_text("Start date must be after #{@mentor.induction_records.first.schedule.milestones.first.start_date.to_date.to_s(:govuk)}")
      end

      def then_i_should_see_blank_email_date_error_message
        expect(page).to have_text("Enter an email")
      end

      def then_i_should_see_invalid_email_date_error_message
        expect(page).to have_text("Enter an email address in the correct format, like name@example.com")
      end

      def then_i_should_see_select_option_error_message
        expect(page).to have_text("Choose a mentor")
      end

      def then_i_should_see_the_transferring_participant
        expect(page).to have_selector("h2", text: "Transferring to your school")
        within(:xpath, "//table[@data-test='transferring_in']/tbody/tr[1]") do
          expect(page).to have_xpath(".//td[1]", text: @participant_data[:full_name])
          expect(page).to have_xpath(".//td[2]", text: @lead_provider.name)
          expect(page).to have_xpath(".//td[3]", text: @delivery_partner.name)
        end
      end

      # and

      def and_i_am_signed_in_as_an_induction_coordinator
        @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort_one.school], user: create(:user, full_name: "Carl Coordinator"))
        privacy_policy = create(:privacy_policy)
        privacy_policy.accept!(@induction_coordinator_profile.user)
        sign_in_as @induction_coordinator_profile.user
      end

      def and_there_is_an_ect_who_will_be_transferring
        @participant_profile_ect = create(:ect_participant_profile, schedule: create(:ecf_schedule, cohort: @cohort), user: create(:user, full_name: "Sally Teacher"), school_cohort: @school_cohort_two)
        create(:ecf_participant_validation_data, participant_profile: @participant_profile_ect, full_name: "Sally Teacher", trn: "1001000", date_of_birth: Date.new(1990, 10, 24))
        @participant_profile_ect.teacher_profile.update!(trn: "1001000")
        Induction::Enrol.call(participant_profile: @participant_profile_ect, start_date: Date.new(Cohort.current.start_year, 9, 1), induction_programme: @induction_programme_two)
      end

      def and_it_should_list_the_schools_mentors
        expect(page).to have_text(@mentor.user.full_name)
      end

      def and_the_participant_should_be_notified_with(notification_method)
        expect(ParticipantTransferMailer).to have_received(notification_method)
                                               .with(hash_including(
                                                       induction_record: @participant_profile_ect.induction_records.latest,
                                                     ))
      end

      def and_the_schools_current_provider_is_notified_with(notification_method)
        induction_record = @participant_profile_ect.induction_records.latest
        expect(ParticipantTransferMailer).to have_received(notification_method)
                                               .with(hash_including(
                                                       induction_record:,
                                                       lead_provider_profile: @lead_provider_profile,
                                                     ))
      end

      def and_i_have_selected_my_cohort_tab
        click_on @cohort.description
      end

      def allow_participant_transfer_mailers
        allow(ParticipantTransferMailer).to receive(:participant_transfer_in_notification).and_call_original
        allow(ParticipantTransferMailer).to receive(:provider_existing_school_transfer_notification).and_call_original
      end

      def set_dqt_validation_result
        allow(DqtRecordCheck).to receive(:call).and_return(
          DqtRecordCheck::CheckResult.new(
            valid_dqt_response(@participant_data),
            true,
            true,
            true,
            false,
            3,
          ),
        )
      end

      def valid_dqt_response(participant_data)
        DqtRecordPresenter.new({
          "name" => participant_data[:full_name],
          "trn" => participant_data[:trn],
          "state_name" => "Active",
          "dob" => participant_data[:date_of_birth],
          "qualified_teacher_status" => { "qts_date" => 1.year.ago },
          "induction" => {
            "start_date" => 1.month.ago,
            "status" => "Active",
          },
        })
      end

      def set_participant_data
        @participant_data = {
          trn: "1001000",
          full_name: "Sally Teacher",
          date_of_birth: Date.new(1990, 10, 24),
          email: "sally-teacher@example.com",
        }
      end
    end
  end
end
