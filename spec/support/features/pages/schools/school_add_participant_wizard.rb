# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolAddParticipantWizard < ::Pages::BasePage
    set_url "/schools/{slug}/participants/who"
    set_primary_heading "Who do you want to add?"

    def add_participant(participant_type, full_name, email_address, start_date, participant_trn = nil, date_of_birth = nil, mentor_full_name = nil)
      case participant_type
      when "ECT"
        add_ect full_name,
                email_address,
                start_date,
                participant_trn,
                date_of_birth,
                mentor_full_name
      when "Mentor"
        add_mentor full_name,
                   email_address,
                   participant_trn,
                   date_of_birth
      when "SIT"
        choose_to_add_self_as_mentor
      end
    end

    # def add_participant_from_another_school(participant_type, full_name, email_address, start_date, participant_trn = nil, date_of_birth = nil, mentor_full_name = nil)
    #   case participant_type
    #   when "ECT"
    #     transfer_ect full_name,
    #       email_address,
    #       start_date,
    #       participant_trn,
    #       date_of_birth,
    #       mentor_full_name
    #   when "Mentor"
    #     transfer_mentor full_name,
    #       email_address,
    #       participant_trn,
    #       date_of_birth
    #   end
    # end

    def add_ect(full_name, trn, date_of_birth, email_address, _start_date, mentor_full_name = nil)
      choose_to_add_a_new_ect

      add_full_name full_name
      add_teacher_reference_number full_name, trn
      add_date_of_birth date_of_birth
      add_email_address full_name, email_address
      # add_start_date start_date
      choose_a_mentor mentor_full_name if mentor_full_name.present?

      confirm_and_add
    end

    def add_mentor(full_name, trn, date_of_birth, email_address)
      choose_to_add_a_new_mentor
      add_mentor_full_name full_name
      add_teacher_reference_number full_name, trn
      add_date_of_birth date_of_birth
      add_email_address full_name, email_address

      confirm_and_add
    end

    def transfer_ect(full_name, email_address, start_date, same_provider, trn, date_of_birth)
      choose_to_add_a_new_ect

      add_full_name full_name
      add_teacher_reference_number full_name, trn
      add_date_of_birth date_of_birth

      confirm_transfer

      add_start_date start_date
      add_email_address full_name, email_address
      # choose_a_mentor mentor_full_name if mentor_full_name.present?

      choose_schools_current_training_provider unless same_provider
      confirm_and_transfer
    end

    def transfer_mentor(full_name, email_address, start_date, same_provider, trn, date_of_birth)
      choose_to_add_a_new_mentor
      add_mentor_full_name full_name
      add_teacher_reference_number full_name, trn
      add_date_of_birth date_of_birth
      choose_only_mentor_at_your_school

      add_start_date start_date
      add_email_address full_name, email_address
      choose_schools_current_training_provider unless same_provider

      confirm_and_transfer
    end

    def choose_to_add_a_new_ect
      choose "ECT"
      click_on "Continue"
      click_on "Continue"

      self
    end

    def choose_to_add_a_new_mentor
      choose "Mentor"
      click_on "Continue"
      click_on "Continue"

      self
    end

    def choose_to_add_self_as_mentor
      choose "Yourself as a mentor"
      click_on "Continue"
      click_on "Confirm"

      self
    end

    def choose_summer_term
      choose option: "summer", allow_label_click: true
      click_on "Continue"

      self
    end

    def add_full_name(participant_name)
      # TODO: is this label correct? it is visually hidden, but pretty sure it should be proper english
      fill_in "What’s this ECT’s full name?", with: participant_name
      click_on "Continue"

      self
    end

    def add_mentor_full_name(participant_name)
      fill_in "What’s this mentor’s full name?", with: participant_name
      click_on "Continue"

      self
    end

    def add_teacher_reference_number(full_name, trn)
      fill_in "What’s #{full_name}’s teacher reference number (TRN)?", with: trn
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

    def add_email_address(full_name, participant_email)
      fill_in "What’s #{full_name}’s email address?", with: participant_email
      click_on "Continue"

      self
    end

    def add_nino(participant_name, participant_nino)
      fill_in "What’s #{participant_name}’s National Insurance number?", with: participant_nino
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

    def add_start_term(start_term)
      choose start_term
      click_on "Continue"

      self
    end

    def choose_a_mentor(mentor_full_name)
      choose mentor_full_name
      click_on "Continue"

      self
    end

    def choose_mentor_later
      choose "Assign mentor later"
      click_on "Continue"

      self
    end

    def confirm_transfer
      click_on "Confirm"

      self
    end

    def choose_only_mentor_at_your_school
      choose "Yes"
      click_on "Confirm"

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

      Pages::SchoolAddParticipantCompletedPage.loaded
    end

    def confirm_and_transfer
      click_on "Confirm and add"

      Pages::SchoolTransferParticipantCompletedPage.loaded
    end

    def confirm_details_and_continue
      click_on "Continue"

      self
    end
  end
end
