# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class ReasonToChangeSchoolParticipantNamePage < ::Pages::BasePage
    # Uncomment this line when FeatureFlag.active?(:cohortless_dashboard) gets removed and its code merged
    #   set_url "/schools/{slug}/participants/{participant_id}/edit-name"

    # Replace this line with
    #   set_url "/schools/{slug}/cohorts/{cohort}/participants/{participant_id}/edit-name"
    # if FeatureFlag.active?(:cohortless_dashboard) gets removed and its code removed (i.e. no cohortless in the service)
    set_url_matcher(/schools\/([^\/]+)(\/cohorts\/([^\/]+))?\/participants\/([^\/]+)\/edit-name/)

    set_primary_heading(/\AWhy do you need to edit (.*)’s name\?\z/)

    def choose_name_is_incorrect
      choose("Their name has been entered incorrectly")
      click_on("Continue")

      Pages::EditSchoolParticipantNamePage.loaded
    end

    def choose_replaced_by_a_different_person
      choose("I want to replace them with a different person")
      click_on("Continue")

      Pages::SchoolParticipantReplacedByADifferentPersonPage.loaded
    end

    def choose_should_not_be_registered
      choose("This teacher should not have been registered on this service")
      click_on("Continue")

      Pages::SchoolParticipantShouldNotHaveBeenRegisteredPage.loaded
    end

    def choose_they_have_changed_their_name
      choose("They’ve changed their name - for example, due to marriage or divorce")
      click_on("Continue")

      Pages::EditSchoolParticipantNamePage.loaded
    end

    def confirm_the_participant(name:)
      element_has_content?(header, "Why do you need to edit #{name}’s name?")
    end
  end
end
