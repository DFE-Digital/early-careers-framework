# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddAppropriateBodyStartPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/appropriate-body/appropriate-body-type"
        set_primary_heading "Which type of appropriate body have you appointed?"

        def report_appropriate_body_type(type = :teaching_school_hub)
          type = type.downcase.to_sym if type.is_a?(String)

          case type
          when :local_authority
            choose "Local authority"
          when :national_organisation
            choose "National organisation"
          when :teaching_school_hub
            choose "Teaching school hub"
          else
            raise ArgumentError, "expected appropriate_body_type to be one of :local_authority, :national_organisation or :teaching_school_hub but got #{type}"
          end

          click_on "Continue"

          ::Pages::Schools::Pages::AddAppropriateBodyChoosePage.loaded
        end
      end
    end
  end
end
