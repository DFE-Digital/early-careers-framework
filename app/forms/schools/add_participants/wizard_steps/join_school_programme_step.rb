# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class JoinSchoolProgrammeStep < ::WizardStep
        attr_accessor :join_school_programme

        validates :join_school_programme,
                  inclusion: { in: %w[default_for_participant_cohort default_for_current_cohort other_providers] }

        def self.permitted_params
          %i[
            join_school_programme
          ]
        end

        def choices
          options = [default_participant_cohort_choice].compact
          options << default_current_cohort_choice if default_current_cohort_choice?
          options << other_providers_choice if options.present?

          options
        end

        def next_step
          if wizard.join_school_programme?
            :check_answers
          else
            :cannot_add_manual_transfer
          end
        end

      private

        def current_cohort_provider_names
          return if [wizard.current_cohort_lead_provider, wizard.current_cohort_delivery_partner].any?(&:blank?)

          @current_cohort_provider_names ||= "#{wizard.current_cohort_lead_provider&.name} with #{wizard.current_cohort_delivery_partner&.name}"
        end

        def default_current_cohort_choice?
          return false unless current_cohort_provider_names

          participant_cohort_provider_names != current_cohort_provider_names
        end

        def default_current_cohort_choice
          if current_cohort_provider_names
            OpenStruct.new(id: :default_for_current_cohort, name: current_cohort_provider_names)
          end
        end

        def default_participant_cohort_choice
          if participant_cohort_provider_names
            OpenStruct.new(id: :default_for_participant_cohort, name: participant_cohort_provider_names)
          end
        end

        def other_providers_choice
          OpenStruct.new(id: :other_providers, name: "Another training providers or programme")
        end

        def participant_cohort_provider_names
          return if [wizard.lead_provider, wizard.delivery_partner].any?(&:blank?)

          @participant_cohort_provider_names ||= "#{wizard.lead_provider&.name} with #{wizard.delivery_partner&.name}"
        end
      end
    end
  end
end
