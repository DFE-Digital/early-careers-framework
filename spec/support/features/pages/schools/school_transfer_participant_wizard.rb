# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolTransferParticipantWizard < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/participants/add/who"
    set_primary_heading "Who do you want to add?"

    def transfer_participant(participant_type, full_name, email_address, start_date, same_provider, participant_trn, date_of_birth)
      case participant_type
      when "ECT"
        transfer_ect(full_name, email_address, start_date, same_provider, participant_trn, date_of_birth)
      when "Mentor"
        transfer_mentor(full_name, email_address, start_date, same_provider, participant_trn, date_of_birth)
      end
    end

    def transfer_ect(full_name, email_address, start_date, same_provider, participant_trn, date_of_birth)
      choose_to_add_a_new_ect

      add_full_name full_name

      if participant_trn.blank?
        choose_i_do_not_know_the_participants_trn
      else
        choose_i_know_the_participants_trn
        add_teacher_reference_number full_name, participant_trn
        add_date_of_birth date_of_birth
      end

      choose_to_transfer_from_another_school
      add_start_date start_date
      add_email_address email_address

      if same_provider
        # UI does not ask about provider
      else
        choose_schools_current_training_provider
        # choose_participants_current_training_provider
        # choose_a_new_training_provider
      end

      confirm_and_add
    end

    def transfer_mentor(full_name, email_address, start_date, same_provider, participant_trn, date_of_birth)
      choose_to_add_a_new_ect

      add_full_name full_name

      if participant_trn.blank?
        choose_i_do_not_know_the_participants_trn
      else
        choose_i_know_the_participants_trn
        add_teacher_reference_number full_name, participant_trn
        add_date_of_birth date_of_birth
      end

      choose_to_transfer_from_another_school
      add_start_date start_date
      add_email_address email_address

      if same_provider
        # UI does not ask about provider
      else
        choose_schools_current_training_provider
        # choose_participants_current_training_provider
        # choose_a_new_training_provider
      end

      confirm_and_add
    end

    def choose_to_add_a_new_ect
      choose "A new ECT"
      click_on "Continue"

      self
    end

    def choose_to_add_a_new_mentor
      choose "A new mentor"
      click_on "Continue"

      self
    end

    def choose_to_transfer_from_another_school
      element_has_content? self, "Is The Participant transferring from another school?"
      choose "Yes"
      click_on "Continue"

      self
    end

    def start_to_add_sit_as_mentor
      click_on "Add yourself as a mentor"
      click_on "Continue"

      self
    end

    def add_full_name(participant_name)
      # TODO: is this label correct? it is visually hidden, but pretty sure it should be proper english
      fill_in "Full_name", with: participant_name
      click_on "Continue"

      self
    end

    def choose_i_know_the_participants_trn
      choose "Yes"
      click_on "Continue"

      self
    end

    def add_teacher_reference_number(full_name, trn)
      element_has_content? self, "What’s #{full_name.titleize}’s teacher reference number (TRN)?"

      fill_in "What’s #{full_name.titleize}’s teacher reference number (TRN)?", with: trn
      click_on "Continue"

      self
    end

    def add_date_of_birth(date_of_birth)
      fill_in "Day", with: date_of_birth.day
      fill_in "Month", with: date_of_birth.month
      fill_in "Year", with: date_of_birth.year
      click_on "Continue"

      self
    end

    def choose_i_do_not_know_the_participants_trn
      choose "No"
      click_on "Continue"

      self
    end

    def add_start_date(start_date)
      fill_in "Day", with: start_date.day
      fill_in "Month", with: start_date.month
      fill_in "Year", with: start_date.year
      click_on "Continue"

      self
    end

    def add_email_address(participant_email)
      fill_in "Email", with: participant_email
      click_on "Continue"

      self
    end

    def choose_schools_current_training_provider
      choose "No"
      click_on "Continue"

      choose "Yes"
      click_on "Continue"

      self
    end

    def confirm_and_add
      click_on "Confirm and add"

      Pages::SchoolTransferParticipantCompletedPage.loaded
    end
  end
end
