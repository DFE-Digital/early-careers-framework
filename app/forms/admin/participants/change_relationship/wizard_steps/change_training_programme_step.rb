# frozen_string_literal: true

module Admin
  module Participants
    module ChangeRelationship
      module WizardSteps
        class ChangeTrainingProgrammeStep < ::WizardStep
          attr_accessor :selected_partnership

          validate :selected_partnership_is_permitted

          def self.permitted_params
            %i[
              selected_partnership
            ]
          end

          # first step
          def expected?
            wizard.programme_can_be_changed?
          end

          def next_step
            if mistake? && !wizard.programme_can_be_changed?
              # if there are declarations then we cannot proceed with the journey
              :cannot_change_programme
            end
          end

          def options
            list = [
              OpenStruct.new(id: :new, name: "<strong>Create new relationship</strong>".html_safe),
            ]
            available = wizard.school_partnerships - [wizard.current_partnership, wizard.school_default_partnership]
            list << available.map do |partnership|
              OpenStruct.new(id: partnership.id, name: partnership_label(partnership))
            end
            list.flatten
          end

        private

          def selected_partnership_is_permitted
            errors.add(:selected_partnership, :blank) and return if selected_partnership.blank?

            errors.add(:selected_partnership, :inclusion) unless options.map(&:id).include? selected_partnership
          end

          def mistake?
            reason_for_change == "wrong_programme"
          end

          def partnership_label(partnership)
            label = []
            label << "<strong>Default partnership:</strong>" unless partnership.relationship?
            label << "#{partnership.lead_provider.name} / #{partnership.delivery_partner&.name}"
            label.join(" ").html_safe
          end
        end
      end
    end
  end
end
