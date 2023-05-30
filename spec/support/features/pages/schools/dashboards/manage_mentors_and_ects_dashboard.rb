# frozen_string_literal: true

module Pages
  module Schools
    module Dashboards
      class ManageMentorsAndEctsDashboard < ::Pages::BasePage
        set_url "/schools/{slug}/participants"
        set_primary_heading "Manage mentors and ECTs"

        def start_add_ect_or_mentor_wizard
          click_on "Add ECT or mentor"

          ::Pages::Schools::Wizards::AddEctOrMentorWizard.loaded
        end
      end
    end
  end
end
