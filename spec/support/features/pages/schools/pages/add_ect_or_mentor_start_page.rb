# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctOrMentorStartPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/who"
        set_primary_heading "Who do you want to add?"

        def choose_ect
          choose "ECT"
          click_on "Continue"

          ::Pages::Schools::Wizards::AddEctWizard.loaded
        end

        def choose_mentor
          choose "Mentor"
          click_on "Continue"

          self
        end

        def choose_sit_mentor
          choose "Yourself as a mentor"
          click_on "Continue"

          self
        end
      end
    end
  end
end
