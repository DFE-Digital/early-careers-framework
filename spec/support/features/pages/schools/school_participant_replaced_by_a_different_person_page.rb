# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantReplacedByADifferentPersonPage < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/participants/{participant_id}/edit-name"
    set_primary_heading(/\AYou cannot make that change by editing (.*)’s name\z/)

    def cant_edit_the_participant_name(name)
      element_has_content?(header, "You cannot make that change by editing #{name}’s name")
    end

    def can_add_a_participant(type)
      click_on "Add a new #{type}"

      element_has_content?(self, "Who do you want to add?")
    end
  end
end
