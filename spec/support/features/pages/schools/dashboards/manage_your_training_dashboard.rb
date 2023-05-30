# frozen_string_literal: true

module Pages
  module Schools
    module Dashboards
      class ManageYourTrainingDashboard < ::Pages::BasePage
        set_url "/schools/{slug}"
        set_primary_heading "Manage your training"

        attr_reader :current_tab_label, :current_tab_element, :current_tab_id

        def switch_to_manage_mentors_and_ects_dashboard
          click_on "Manage mentors and ECTs"

          ::Pages::Schools::Dashboards::ManageMentorsAndEctsDashboard.loaded
        end

        def start_change_induction_tutor_wizard
          click_on "Change induction tutor"

          self
        end

        def choose_academic_year(academic_year: nil)
          academic_year = Cohort.current if academic_year.blank?

          click_on academic_year.description

          @current_tab_label = academic_year.description
          @current_tab_element = find_link(text: @current_tab_label)
          @current_tab_id = @current_tab_element[:href]

          self
        end

        def start_add_appropriate_body_wizard
          raise "Need to 'choose_academic_year()' first" if @current_tab_id.blank?

          within(@current_tab_id) do
            click_on "Add"
          end

          ::Pages::Schools::Wizards::ChooseAppropriateBodyWizard.loaded
        end

        def start_choose_materials_wizard
          raise "Need to 'choose_academic_year()' first" if @current_tab_id.blank?

          within(@current_tab_id) do
            click_on "Choose materials"
          end

          ::Pages::Schools::Wizards::ChooseCoreProgrammeMaterialsWizard.loaded
        end

        def start_change_programme_wizard
          raise "Need to 'choose_academic_year()' first" if @current_tab_id.blank?

          within(@current_tab_id) do
            click_on "Change induction programme choice"
          end

          self
        end

        def start_change_appropriate_body_wizard
          raise "Need to 'choose_academic_year()' first" if @current_tab_id.blank?

          within(@current_tab_id) do
            click_on "Change"
          end

          self
        end

        def start_change_materials_wizard
          raise "Need to 'choose_academic_year()' first" if @current_tab_id.blank?

          within(@current_tab_id) do
            click_on "Change materials"
          end

          self
        end

        def start_setup_programme_wizard
          raise "Need to 'choose_academic_year()' first" if @current_tab_id.blank?

          within(@current_tab_id) do
            click_on "Tell us if this has changed"
          end

          self
        end
      end
    end
  end
end
