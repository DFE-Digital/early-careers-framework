# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantsDashboardPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants"
    set_primary_heading "Manage mentors and ECTs"

    def choose_to_add_an_ect_or_mentor
      click_on "Add ECT or mentor"

      Pages::SchoolAddParticipantWizard.loaded
    end

    def choose_to_transfer_an_ect_or_mentor
      click_on "Add ECT or mentor"

      Pages::SchoolTransferParticipantWizard.loaded
    end

    def filter_by(option)
      choose("filtered-by-#{option.downcase.parameterize}-field")
      click_on("Apply filter")
    end

    def view_participant(participant_name)
      find_participant(participant_name)
      click_on(participant_name)

      Pages::SchoolParticipantDetailsPage.loaded
    end

  private

    def find_participant(name)
      return if has_link?(name)

      filter_by("No longer training")
      return if has_link?(name)

      filter_by("Completed induction")
      return if has_link?(name)

      filter_by("Currently training")
    end
  end
end
