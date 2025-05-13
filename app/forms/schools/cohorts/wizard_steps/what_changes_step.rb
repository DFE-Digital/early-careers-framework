# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class WhatChangesStep < ::WizardStep
        attr_accessor :what_changes

        validates :what_changes, inclusion: { in: ->(form) { form.choices.map(&:id).map(&:to_s) } }

        def self.permitted_params
          %i[what_changes]
        end

        def choices
          if FeatureFlag.active?(:programme_type_changes_2025)
            [
              OpenStruct.new(id: :change_lead_provider,               name: "Form a new partnership"),
              OpenStruct.new(id: :change_to_core_induction_programme, name: "Deliver a school-led programme"),
            ]
          else
            [
              OpenStruct.new(id: :change_lead_provider,               name: "Form a new partnership"),
              OpenStruct.new(id: :change_to_core_induction_programme, name: "Deliver your own programme using DfE-accredited materials"),
              OpenStruct.new(id: :change_to_design_our_own,           name: "Design and deliver your own programme based on the early career framework (ECF)"),
            ]
          end
        end

        def expected?
          return true if wizard.no_keep_providers?

          wizard.expect_any_ects? && wizard.previously_fip? && !wizard.provider_relationship_is_valid?
        end

        def next_step
          :what_changes_confirmation
        end
      end
    end
  end
end
