# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class AppropriateBodyStep < ::WizardStep
        attr_accessor :appropriate_body_id, :appropriate_body_type

        before_validation :ensure_appropriate_body_id

        validates :appropriate_body_id, inclusion: { in: ->(form) { form.choices.map(&:id) }, message: 'Select a teaching school hub' }, if: :body_type_tsh?
        validates :appropriate_body_type, inclusion: { in: %w[default tsh not_listed], message: 'Specify the type of appropriate body appointed' }

        def self.permitted_params
          %i[appropriate_body_id appropriate_body_type]
        end

        def choices
          @choices ||= AppropriateBody.where(body_type: "teaching_school_hub").selectable_by_schools
        end

        def complete?
          true
        end

        def expected?
          wizard.appropriate_body_appointed?
        end

        def next_step
          :complete
        end

        def body_type_tsh?
          appropriate_body_type == "tsh"
        end

        def ensure_appropriate_body_id
          if appropriate_body_type == "default"
            @appropriate_body_id = wizard.appropriate_body_default_selection.id
          elsif appropriate_body_type == "not_listed"
            wizard.data_store.set(:appropriate_body_appointed, "no")
            @appropriate_body_id = nil
          end
        end
      end
    end
  end
end
