# frozen_string_literal: true

module Pages
  class SITTransferParticipantWizard
    include Capybara::DSL

    def complete(participant_name, participant_email, participant_trn, participant_dob, same_provider)
      click_on "Continue"

      start_to_transfer_a_participant

      add_full_name participant_name
      add_teacher_reference_number participant_trn
      add_date_of_birth participant_dob
      add_start_date year: Time.zone.now.year, month: Time.zone.now.month, day: Time.zone.now.day
      add_email_address participant_email

      unless same_provider
        choose_schools_current_training_provider

        # TODO: when schools have different training provider
        # choose_participants_current_training_provider
        # choose_a_new_training_provider
      end

      confirm_and_add
    end

    def start_to_transfer_a_participant
      start_to_add_a_participant
      choose_to_transfer_from_another_school
      confirm_have_all_details
    end

    def start_to_add_a_participant
      click_on "Add an ECT or mentor"
    end

    def choose_to_transfer_from_another_school
      choose "A teacher transferring from another school where they’ve started ECF-based training or mentoring"
      click_on "Continue"
    end

    def confirm_have_all_details
      click_on "Continue"
    end

    def choose_to_add_a_new_ect
      choose "A new ECT"
      click_on "Continue"
    end

    def choose_to_add_a_new_mentor
      choose "A new mentor"
      click_on "Continue"
    end

    def start_to_add_sit_as_mentor
      click_on "Add yourself as a mentor"
      click_on "Continue"
    end

    def add_full_name(participant_name)
      # TODO: is this label correct? it is visually hidden, but pretty sure it should be proper english
      fill_in "Full_name", with: participant_name
      click_on "Continue"
    end

    def add_teacher_reference_number(trn)
      fill_in "Teacher reference number (TRN)", with: trn
      click_on "Continue"
    end

    def add_date_of_birth(dob)
      fill_in "Day", with: dob[:day]
      fill_in "Month", with: dob[:month]
      fill_in "Year", with: dob[:year]
      click_on "Continue"
    end

    def add_start_date(dob)
      fill_in "Day", with: dob[:day]
      fill_in "Month", with: dob[:month]
      fill_in "Year", with: dob[:year]
      click_on "Continue"
    end

    def add_email_address(participant_email)
      fill_in "Email", with: participant_email
      click_on "Continue"
    end

    def choose_schools_current_training_provider
      puts page.html

      choose "No"
      click_on "Continue"

      choose "Yes"
      click_on "Continue"
    end

    def confirm_and_add
      click_on "Confirm and add"
    end

    def view_participants_dashboard
      click_on "View your ECTs and mentors"

      Pages::SITParticipantsDashboard.new
    end
  end
end
