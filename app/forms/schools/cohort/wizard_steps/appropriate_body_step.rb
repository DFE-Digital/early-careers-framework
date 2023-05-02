# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class AppropriateBodyStep < ::WizardStep
        attr_accessor :appropriate_body_id

        validates :appropriate_body_id, inclusion: { in: ->(form) { form.choices.map(&:id) } }

        def self.permitted_params
          %i[appropriate_body_id]
        end

        def complete?
          true
        end

        def choices
          @choices ||= AppropriateBody.where(body_type: wizard.appropriate_body_type)
        end

        def next_step
          :complete
        end
      end
    end
  end
end
