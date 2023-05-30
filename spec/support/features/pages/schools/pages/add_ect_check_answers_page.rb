# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctCheckAnswersPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/add/check-answers"
        set_primary_heading("Check your answers")

        def confirm_full_name(full_name)
          element_has_content? self, "Name#{full_name}"
        end

        def confirm_trn(trn)
          element_has_content? self, "TRN#{trn}"
        end

        def confirm_date_of_brith(date_of_birth)
          element_has_content? self, "Date of birth#{date_of_birth}"
        end

        def confirm_email_address(email_address)
          element_has_content? self, "Email address#{email_address}"
        end

        def confirm_start_term(start_term)
          element_has_content? self, "Start term#{start_term}"
        end

        def confirm_mentor(mentor_name = nil)
          if mentor_name.nil?
            element_has_content? self, "MentorAdd later"
          else
            element_has_content? self, "Mentor#{mentor_name}"
          end
        end

        def confirm_and_add
          click_on "Confirm and add"

          ::Pages::Schools::Pages::AddEctCompletedPage.loaded
        end
      end
    end
  end
end
