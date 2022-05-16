# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolAddParticipantWizard < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/participants/add/who"
    set_primary_heading "Who do you want to add?"

    def add_participant(participant_type, full_name, email_address, start_term, start_date, participant_trn = nil, date_of_birth = nil, mentor_full_name = nil)
      case participant_type
      when "ECT"
        add_ect full_name,
                email_address,
                start_term,
                start_date,
                participant_trn,
                date_of_birth,
                mentor_full_name
      when "Mentor"
        add_mentor full_name,
                   email_address,
                   start_term,
                   start_date,
                   participant_trn,
                   date_of_birth
      when "SIT"
        choose_to_add_self_as_mentor
      end
    end

    def add_ect(full_name, email_address, start_term, start_date, participant_trn = nil, date_of_birth = nil, mentor_full_name = nil)
      choose_to_add_a_new_ect

      add_full_name full_name

      if participant_trn.blank?
        choose_i_do_not_know_the_participants_trn
      else
        choose_i_know_the_participants_trn
        add_teacher_reference_number full_name, participant_trn
        add_date_of_birth date_of_birth
      end

      add_email_address email_address
      choose_start_term start_term
      add_start_date start_date

      # this will need skipping if no mentors added to the school yet
      if mentor_full_name.present?
        choose_a_mentor mentor_full_name
        # else
        # puts page.html
      end

      confirm_and_add
    end

    def add_mentor(full_name, email_address, start_term, _start_date, participant_trn = nil, date_of_birth = nil)
      choose_to_add_a_new_mentor

      add_full_name full_name

      if participant_trn.blank?
        choose_i_do_not_know_the_participants_trn
      else
        choose_i_know_the_participants_trn
        add_teacher_reference_number full_name, participant_trn
        add_date_of_birth date_of_birth
      end

      add_email_address email_address
      choose_start_term start_term

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

    def choose_to_add_self_as_mentor
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

    def choose_i_do_not_know_the_participants_trn
      choose "No"
      click_on "Continue"

      self
    end

    def add_email_address(participant_email)
      fill_in "Email", with: participant_email
      click_on "Continue"

      self
    end

    def choose_start_term(start_term)
      choose start_term
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

    def choose_a_mentor(mentor_full_name)
      choose mentor_full_name
      click_on "Continue"

      self
    end

    def choose_mentor_later
      puts page.html
      choose "Do this later"
      click_on "Continue"

      self
    end

    def confirm_and_add
      click_on "Confirm and add"

      Pages::SchoolAddParticipantCompletedPage.loaded
    end
  end
end
