# frozen_string_literal: true

require "rails_helper"

RSpec.describe "transferring participants", :with_default_schedules, with_feature_flags: { change_of_circumstances: "active" }, type: :feature, js: true, rutabaga: false do
  context "Attempting to transfer an ECT to a school" do
    context "ECT has been withdrawn" do
      before do
        allow_participant_transfer_mailers
        set_participant_data
        set_dqt_validation_result
        given_there_are_two_schools_that_have_chosen_fip_for_current_cohort_and_partnered
        and_there_is_a_withdrawn_ect_who_will_be_transferring
        and_i_am_signed_in_as_an_induction_coordinator
        and_i_have_selected_my_cohort_tab
        when_i_click_to_view_ects_and_mentors
        then_i_am_taken_to_your_ect_and_mentors_page
      end

      scenario "SIT can transfer a withdrawn participant" do
        when_i_click_to_add_a_new_ect_or_mentor
        then_i_should_be_on_the_who_to_add_page

        when_i_select_transfer_teacher_option
        click_on "Continue"
        then_i_should_be_on_what_we_need_page

        click_on "Continue"
        then_i_should_be_on_full_name_page

        when_i_update_the_name_with("Sally Teacher")
        click_on "Continue"
        then_i_should_be_on_trn_page

        when_i_add_a_valid_trn
        click_on "Continue"
        then_i_should_be_on_the_date_of_birth_page

        when_i_add_a_valid_date_of_birth
        click_on "Continue"

        then_i_should_be_on_the_teacher_start_date_page
        when_i_add_a_valid_start_date
        click_on "Continue"

        then_i_should_be_on_the_add_email_page
        when_i_update_the_email_with("sally-teacher@example.com")
        click_on "Continue"

        then_i_should_be_on_the_select_mentor_page
        and_it_should_list_the_schools_mentors
        when_i_assign_a_mentor
        click_on "Continue"

        then_i_should_be_taken_to_the_check_your_answers_page
        click_on "Confirm and add"
        then_i_should_be_on_the_complete_page

        and_the_participant_should_be_notified_with(:participant_transfer_in_notification)
        and_the_schools_current_provider_is_notified_with(:provider_transfer_in_notification)

        click_on "View your ECTs and mentors"
        then_i_am_taken_to_your_ect_and_mentors_page
      end

      # given

      def given_there_are_two_schools_that_have_chosen_fip_for_current_cohort_and_partnered
        @cohort = Cohort.current
        @school_one = create(:school, name: "Fip School 1")
        @school_two = create(:school, name: "Fip School 2")
        create(:school_cohort, :fip, :with_induction_programme, school: @school_one, cohort: Cohort.next || create(:cohort, :next))
        @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
        @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
        @school_cohort_one = create(:school_cohort, :fip, :with_induction_programme, school: @school_one, cohort: @cohort, lead_provider: @lead_provider, delivery_partner: @delivery_partner)

        @lead_provider_two = create(:lead_provider, name: "Massive Provider Ltd")
        @other_delivery_partner = create(:delivery_partner, name: "Fantastic Delivery Team")
        @school_cohort_two = create(:school_cohort, :fip, :with_induction_programme, school: @school_two, cohort: @cohort, lead_provider: @lead_provider_two, delivery_partner: @other_delivery_partner)

        @lead_provider_profile = create(:lead_provider_profile, lead_provider: @lead_provider)
        @mentor = create(:mentor, user: create(:user, full_name: "Billy Mentor"), school_cohort: @school_cohort_one)

        @induction_programme_one = @school_cohort_one.default_induction_programme
        @induction_programme_two = @school_cohort_two.default_induction_programme
      end

      # when

      def when_i_click_to_view_ects_and_mentors
        click_on("Manage participants")
      end

      def when_i_click_to_add_a_new_ect_or_mentor
        click_on "Add an ECT or mentor"
      end

      def when_i_select_transfer_teacher_option
        choose("A teacher transferring from another school where they’ve started ECF-based training or mentoring", allow_label_click: true)
      end

      def when_i_update_the_name_with(name)
        fill_in "Full_name", with: name
      end

      def when_i_update_the_email_with(email)
        fill_in "Email", with: email
      end

      def when_i_add_a_valid_trn
        fill_in "Teacher reference number (TRN)", with: "1001000"
      end

      def when_i_add_a_valid_date_of_birth
        legend = "What’s #{@participant_data[:full_name]}’s date of birth?"

        fill_in_date(legend, with: "1990-10-24")
      end

      def when_i_add_a_valid_start_date
        legend = "#{@participant_data[:full_name]}’s start date"

        fill_in_date(legend, with: "2023-10-24")
      end

      def when_i_assign_a_mentor
        choose(@mentor.user.full_name)
      end

      def when_i_select(option)
        choose(option)
      end

      # then

      def then_i_am_taken_to_your_ect_and_mentors_page
        expect(page).to have_selector("h1", text: "Your ECTs and mentors")
        expect(page).to have_text("Add an ECT or mentor")
        expect(page).to have_text("Add yourself as a mentor")
      end

      def then_i_should_be_on_what_we_need_page
        expect(page).to have_selector("h1", text: "What we need from you")
        expect(page).to have_text("To do this, you need to tell us their")
      end

      def then_i_should_be_on_full_name_page
        expect(page).to have_selector("h1", text: "What’s this person’s full name?")
      end

      def then_i_should_be_on_trn_page
        expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)?")
      end

      def then_i_should_be_on_the_date_of_birth_page
        expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s date of birth?")
      end

      def then_i_should_be_on_the_who_to_add_page
        expect(page).to have_selector("h1", text: "Who do you want to add?")
      end

      def then_i_should_be_on_the_teacher_start_date_page
        expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s start date at your school")
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
        expect(page).to have_selector("dd", text: @lead_provider_two.name)
        expect(page).to have_selector("dd", text: @other_delivery_partner.name)
      end

      def then_i_should_be_on_the_complete_page
        expect(page).to have_selector("h2", text: "What happens next")
        expect(page).to have_text("We’ll let #{@participant_profile_ect.user.full_name}")
      end

      # and

      def and_i_am_signed_in_as_an_induction_coordinator
        @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort_one.school], user: create(:user, full_name: "Carl Coordinator"))
        privacy_policy = create(:privacy_policy)
        privacy_policy.accept!(@induction_coordinator_profile.user)
        sign_in_as @induction_coordinator_profile.user
      end

      def and_there_is_a_withdrawn_ect_who_will_be_transferring
        @participant_profile_ect = create(:ect, user: create(:user, full_name: "Sally Teacher"), school_cohort: @school_cohort_two)
        induction_record = Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme_two, start_date: 3.months.ago)
        create(:ecf_participant_validation_data, participant_profile: @participant_profile_ect, full_name: "Sally Teacher", trn: "1001000", date_of_birth: Date.new(1990, 10, 24))
        ParticipantProfileState.create!(participant_profile: @participant_profile_ect, state: ParticipantProfileState.states[:withdrawn], cpd_lead_provider: @induction_programme_two.lead_provider&.cpd_lead_provider)
        @participant_profile_ect.training_status_withdrawn!
        induction_record.training_status_withdrawn!
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
        allow(ParticipantTransferMailer).to receive(:provider_transfer_in_notification).and_call_original
      end

      def set_dqt_validation_result
        response = {
          trn: @participant_data[:trn],
          full_name: @participant_data[:full_name],
          nino: nil,
          dob: @participant_data[:date_of_birth],
          config: {},
        }
        allow_any_instance_of(ParticipantValidationService).to receive(:validate).and_return(response)
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
