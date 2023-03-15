# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class NameStep < ::WizardStep
        attr_accessor :full_name

        validates :full_name, presence: { message: I18n.t("errors.full_name.blank") }

        def self.permitted_params
          %i[
            full_name
          ]
        end

        def next_step
          :trn
        end

        def previous_step
          :what_we_need
        end
      end
    end
  end
end
