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
      choose_to_transfer_from_another_school
      confirm_transferring_an_ect_or_mentor

      add_full_name full_name
      add_teacher_reference_number full_name, participant_trn
      add_date_of_birth date_of_birth
      add_start_date start_date
      add_email_address full_name, email_address

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
      choose_to_transfer_from_another_school
      confirm_transferring_an_ect_or_mentor

      add_full_name full_name
      add_teacher_reference_number full_name, participant_trn
      add_date_of_birth date_of_birth
      add_start_date start_date
      add_email_address full_name, email_address

      if same_provider
        # UI does not ask about provider
      else
        choose_schools_current_training_provider
        # choose_participants_current_training_provider
        # choose_a_new_training_provider
      end

      confirm_and_add
    end

    def choose_to_transfer_from_another_school
      choose "A teacher transferring from another school where they’ve started ECF-based training or mentoring"
      click_on "Continue"

      self
    end

    def confirm_transferring_an_ect_or_mentor
      click_on "Continue"

      self
    end

    def add_full_name(participant_name)
      # TODO: is this label correct? it is visually hidden, but pretty sure it should be proper english
      fill_in "What’s this person’s full name?", with: participant_name
      click_on "Continue"

      self
    end

    def add_mentor_full_name(participant_name)
      fill_in "What’s the full name of this mentor?", with: participant_name
      click_on "Continue"

      self
    end

    def add_teacher_reference_number(full_name, trn)
      fill_in "What’s #{full_name}’s teacher reference number (TRN)", with: trn
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

    def add_start_date(start_date)
      fill_in "Day", with: start_date.day
      fill_in "Month", with: start_date.month
      fill_in "Year", with: start_date.year
      click_on "Continue"

      self
    end

    def add_email_address(full_name, participant_email)
      fill_in "What’s #{full_name}’s email address?", with: participant_email
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
