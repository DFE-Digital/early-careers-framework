# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolEarlyCareerTeachersDashboardPage < ::Pages::BasePage
    set_url "/schools/{slug}/early_career_teachers"
    set_primary_heading "Early career teachers (ECTs)"

    def choose_to_add_an_ect
      click_on "Add ECT"

      Pages::SchoolAddParticipantWizard.loaded
    end

    def choose_to_transfer_an_ect
      click_on "Add ECT"

      Pages::SchoolTransferParticipantWizard.loaded
    end

    def filter_by(option)
      choose("filtered-by-#{option.downcase.parameterize}-field")
      click_on("Apply")
    end

    def view_participant(participant_name)
      find_participant(participant_name)
      click_on(participant_name)

      Pages::SchoolEarlyCareerTeacherDetailsPage.loaded
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
