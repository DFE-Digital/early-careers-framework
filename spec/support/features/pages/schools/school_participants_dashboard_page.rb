# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantsDashboardPage < ::Pages::BasePage
    # Uncomment this line when FeatureFlag.active?(:cohortless_dashboard) gets removed and its code merged
    #   set_url "/schools/{slug}/participants"

    # Replace this line with
    #   set_url "/schools/{slug}/cohorts/{cohort}/participants"
    # if FeatureFlag.active?(:cohortless_dashboard) gets removed and its code removed (i.e. no cohortless in the service)
    set_url_matcher(/schools\/([^\/]+)(\/cohorts\/([^\/]+))?\/participants/)

    set_primary_heading "Manage mentors and ECTs"

    def choose_to_add_an_ect_or_mentor
      click_on FeatureFlag.active?(:cohortless_dashboard) ? "Add ECT or mentor" : "Add an ECT or mentor"

      Pages::SchoolAddParticipantWizard.loaded
    end

    def choose_to_transfer_an_ect_or_mentor
      click_on "Add ECT or mentor"

      Pages::SchoolTransferParticipantWizard.loaded
    end

    def visit_participant(participant_name)
      click_on participant_name

      Pages::SchoolParticipantDetailsPage.loaded
    end

    # Remove this code when we remove FeatureFlag.active?(:cohortless_dashboard) - start
    def view_ects(participant_name)
      within "#ects" do
        click_on participant_name
      end

      Pages::SchoolParticipantDetailsPage.loaded
    end

    def view_mentors(participant_name)
      within "#mentors" do
        click_on participant_name
      end

      Pages::SchoolParticipantDetailsPage.loaded
    end

    def view_not_training(participant_name)
      within "#not-training" do
        click_on participant_name
      end

      Pages::SchoolParticipantDetailsPage.loaded
    end
    # Remove this code when we remove FeatureFlag.active?(:cohortless_dashboard) - end
  end
end
