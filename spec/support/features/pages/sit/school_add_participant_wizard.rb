# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolAddParticipantWizard < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/roles"
    set_primary_heading "Check what each person needs to do in the early career teacher training programme"

    def complete(participant_name, participant_email, participant_type, cohort_label)
      click_on "Continue"

      start_to_add_a_participant

      case participant_type.downcase.to_sym
      when :ect
        choose_to_add_a_new_ect
        add_full_name participant_name

        choose "No"
        click_on "Continue"

        add_email_address participant_email
        choose_start_date cohort_label

        fill_in "Day", with: "1"
        fill_in "Month", with: "9"
        fill_in "Year", with: "2021"
        click_on "Continue"

        confirm_and_add
      when :mentor
        choose_to_add_a_new_mentor
        add_full_name participant_name

        choose "No"
        click_on "Continue"

        add_email_address participant_email
        choose_start_date cohort_label

        fill_in "Day", with: "1"
        fill_in "Month", with: "9"
        fill_in "Year", with: "2021"
        click_on "Continue"

        confirm_and_add
      when :sit_mentor
        start_to_add_sit_as_mentor
        raise "Not implemented yet"
      end
    end

    def start_to_add_a_participant
      click_on "Add an ECT or mentor"
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

    def add_email_address(participant_email)
      fill_in "Email", with: participant_email
      click_on "Continue"
    end

    def choose_start_date(cohort_label)
      choose cohort_label
      click_on "Continue"
    end

    def confirm_and_add
      click_on "Confirm and add"
    end

    def view_participants_dashboard
      click_on "View your ECTs and mentors"

      Pages::SchoolParticipantsDashboardPage.loaded
    end
  end
end
