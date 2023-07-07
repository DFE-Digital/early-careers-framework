# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class ChangeTrainingProgrammeStep < ::JourneyWizard::Step
          attr_accessor :selected_partnership

          validates :selected_partnership, inclusion: { in: :permitted_options }

          def self.permitted_params
            %i[
              selected_partnership
            ]
          end

          def expected?
            wizard.programme_can_be_changed?
          end

          def next_step
            if wizard.create_new_partnership?
              :choose_lead_provider
            else
              :confirm_selected_partnership
            end
          end

          def options
            list = [
              OpenStruct.new(id: "create_new", name: "Create new relationship"),
            ]
            available = wizard.school_partnerships - [wizard.current_partnership]
            list << available.map do |partnership|
              OpenStruct.new(id: partnership.id, name: partnership_label(partnership))
            end
            list.flatten
          end

        private

          def permitted_options
            options.map(&:id)
          end

          def partnership_label(partnership)
            label = []
            label << "Default partnership:" unless partnership.relationship?
            label << "#{partnership.lead_provider.name} / #{partnership.delivery_partner&.name}"
            label.join(" ")
          end
        end
      end
    end
  end
end
