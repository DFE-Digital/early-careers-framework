# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolMentorsDashboardPage < ::Pages::BasePage
    set_url "/schools/{slug}/mentors"
    set_primary_heading "Mentors"

    def choose_to_add_a_mentor
      click_on "Add Mentor"

      Pages::SchoolAddParticipantWizard.loaded
    end

    def choose_to_transfer_a_mentor
      click_on "Add Mentor"

      Pages::SchoolTransferParticipantWizard.loaded
    end

    def filter_by(option)
      choose("filtered-by-#{option.downcase.parameterize}-field")
      click_on("Apply")
    end

    def view_participant(participant_name)
      find_participant(participant_name)
      click_on(participant_name)

      Pages::SchoolMentorDetailsPage.loaded
    end

  private

    def find_participant(name)
      return if has_link?(name)

      if has_link?("No longer training")
        filter_by("No longer training")
        return if has_link?(name)
      end

      if has_link?("Completed induction")
        filter_by("Completed induction")
        return if has_link?(name)
      end

      if has_link?("Currently training")
        filter_by("Currently training")
      end
    end
  end
end
