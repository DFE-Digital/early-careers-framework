# frozen_string_literal: true

module Schools
  module Cohort
    class BaseWizard < Wizard
      def self.permitted_params_for(step)
        "Schools::Cohort::WizardSteps::#{step.to_s.camelcase}Step".constantize.permitted_params
      end

      def self.steps
        Schools::Cohort::WizardSteps
          .constants
          .select { |constant| constant.name.end_with?("Step") }
          .map { |constant| constant.name.chomp("Step").underscore.to_sym }
      end

      attr_reader :cohort, :school

      def initialize(cohort:, school:, **opts)
        super
        store_cohort!(cohort)
        store_school!(school)
      end

      def path_options(step: nil)
        { cohort_id: cohort.start_year, school_id: school.slug }.tap do |options|
          options.merge!(step: step.to_s.dasherize) if step.present?
        end
      end

      def store_cohort!(cohort)
        if data_store.cohort_start_year.present? && data_store.cohort_start_year != cohort.start_year
          raise AlreadyInitialised, "cohort different"
        end

        data_store.set(:cohort_start_year, cohort.start_year)
        @cohort = cohort
      end

      def store_school!(school)
        if data_store.school_id.present? && data_store.school_id != school.slug
          raise AlreadyInitialised, "school different"
        end

        data_store.set(:school_id, school.slug)
        @school = school
      end
    end
  end
end
