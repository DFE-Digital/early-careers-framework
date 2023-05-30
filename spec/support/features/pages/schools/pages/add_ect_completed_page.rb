# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctCompletedPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/add/complete"
        set_primary_heading(/(.*) has been added as an ECT/)

        def has_correct_full_name?(full_name)
          element_has_content?(header, "#{full_name} has been added as an ECT")
        end

        def return_to_manage_mentors_and_ects
          click_on "View your ECTs and mentors"

          ::Pages::Schools::Dashboards::ManageMentorsAndEctsDashboard.loaded
        end
      end
    end
  end
end
