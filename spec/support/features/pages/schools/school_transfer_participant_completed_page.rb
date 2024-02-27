# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolTransferParticipantCompletedPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants/transfer/complete"
    set_primary_heading(/^.* has been added as (an ECT|a mentor)$/)

    def confirm_has_full_name(full_name)
      element_has_content? header, "#{full_name} has been added"
      self
    end

    def view_your_ects
      click_on "Early career teacher"

      Pages::SchoolEarlyCareerTeachersDashboardPage.loaded
    end
  end
end
