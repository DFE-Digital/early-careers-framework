# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class ChoosePartnershipStep < ::WizardStep
        attr_accessor :providers

        validates :providers,
                  inclusion: { in: %w[current_providers previous_providers other_providers] }

        def self.permitted_params
          %i[
            providers
          ]
        end

        def choices
          options = Array(current_providers_choice)
          options << previous_providers_choice if previous_providers_choice?
          options << other_providers_choice if options.present?

          options
        end

        def next_step
          if wizard.providers_chosen?
            :check_answers
          else
            :cannot_add_mentor_to_providers
          end
        end

      private

        def current_providers_choice
          if current_providers_names
            OpenStruct.new(id: :current_providers, name: current_providers_names)
          end
        end

        def current_providers_names
          return if [wizard.lead_provider, wizard.delivery_partner].any?(&:blank?)

          @current_providers_names ||= "#{wizard.lead_provider&.name} with #{wizard.delivery_partner&.name}"
        end

        def previous_providers_names
          return if [wizard.previous_cohort_lead_provider, wizard.previous_cohort_delivery_partner].any?(&:blank?)

          @previous_providers_names ||= "#{wizard.previous_cohort_lead_provider&.name} with #{wizard.previous_cohort_delivery_partner&.name}"
        end

        def previous_providers_choice
          if previous_providers_names
            OpenStruct.new(id: :previous_providers, name: previous_providers_names)
          end
        end

        def previous_providers_choice?
          return false if previous_providers_names == current_providers_names

          wizard.previous_providers_training_on_current_cohort?
        end

        def other_providers_choice
          OpenStruct.new(id: :other_providers, name: "Other training providers")
        end
      end
    end
  end
end
