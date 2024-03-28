# frozen_string_literal: true

require_relative "../base_page"

module Pages::AddAppropriateBody
  class TypePage < ::Pages::BasePage
    set_url_matcher /appropriate-body\/appropriate-body-type$/
    set_primary_heading "Which type of appropriate body have you appointed?"

    def choose_national_organisation
      choose "National organisation"
      click_on "Continue"
      Pages::AddAppropriateBody::SelectNationalOrganisationPage.loaded
    end

    def choose_teaching_school_hub
      choose "Teaching school hub"
      click_on "Continue"
    end
  end

  class SelectNationalOrganisationPage < ::Pages::BasePage
    set_url_matcher /appropriate-body\/appropriate-body$/
    set_primary_heading "Which national appropriate body have you appointed?"

    def choose_element(element)
      choose element
      click_on "Continue"
      Pages::AddAppropriateBody::ConfirmationPage.loaded
    end
  end

  class ConfirmationPage < ::Pages::BasePage
    set_url_matcher /appropriate-body\/confirm/
    set_primary_heading "Appropriate body reported"

    def return_to_manage_training
      click_on "Return to manage your training"
    end
  end
end
