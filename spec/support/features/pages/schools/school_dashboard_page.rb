# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolDashboardPage < ::Pages::BasePage
    set_url "/schools/{slug}"
    set_primary_heading "Manage your training"

    def has_induction_tutor?(sit)
      full_name = case sit.class
                  when InductionCoordinatorProfile
                    sit.user.full_name
                  when User
                    sit.full_name
                  else
                    sit.to_s
                  end

      element_has_content? self, "Induction tutor #{full_name}"
    end

    def confirm_has_no_participants
      element_has_content?(self, "ECTs0")
    end

    def confirm_will_use_dfe_funded_training_provider
      element_has_content? self, "Programme Use a training provider funded by the DfE"
    end

    def confirm_is_using_dfe_accredited_materials
      element_has_content? self, "Programme DfE-accredited materials"
    end

    def report_school_has_been_confirmed_incorrectly
      click_on "report that your school has been confirmed incorrectly"

      Pages::ReportIncorrectPartnershipPage.loaded
    end

    def confirm_can_report_school_has_been_confirmed_incorrectly
      element_has_content? self, "report that your school has been confirmed incorrectly"
    end

    def confirm_cannot_report_school_has_been_confirmed_incorrectly
      element_without_content? self, "report that your school has been confirmed incorrectly"
    end

    def view_participant_details
      click_on("Manage mentors and ECTs")

      Pages::SchoolParticipantsDashboardPage.loaded
    end

    def add_participant_details
      click_on("Manage mentors and ECTs")

      Pages::SchoolParticipantsDashboardPage.loaded
    end

    def add_cip_materials(cip_materials_name)
      click_on "Tell us which materials you’ll use"

      # Pages::SchoolAddCIPMaterialsWizard.loaded
      click_on "Continue"

      choose cip_materials_name
      click_on "Continue"

      # Pages::SchoolAddCIPMaterialsCompletedPage.loaded
      click_on "Return to manage your training"

      SchoolDashboardPage.loaded
    end

    def choose_cip_materials(cip_materials_name)
      click_on "Choose materials"

      # Pages::SchoolAddCIPMaterialsWizard.loaded
      click_on "Continue"

      choose cip_materials_name
      click_on "Continue"

      # Pages::SchoolAddCIPMaterialsCompletedPage.loaded
      click_on "Return to manage your training"

      SchoolDashboardPage.loaded
    end

    def add_appropriate_body(appropriate_body_name, appropriate_body_type)
      click_on "Add"

      # Pages::SchoolAddAppropriateBodyWizard.loaded
      #                                      .complete(appropriate_body_name, appropriate_body_type)

      # .with_type(appropriate_body_type)
      case appropriate_body_type
      when :local_authority
        choose "Local authority"
      when :teaching_school_hub
        choose "Teaching school hub"
      when :national
        choose "National"
      else
        choose "Local authority"
      end
      click_on "Continue"

      # .with_name(appropriate_body_name)
      select appropriate_body_name
      click_on "Continue"

      # Pages::SchoolAddAppropriateBodyCompletedPage.loaded
      click_on "Return to manage your training"

      SchoolDashboardPage.loaded
    end
  end
end
