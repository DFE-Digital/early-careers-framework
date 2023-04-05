# frozen_string_literal: true

module Schools
  module AddParticipants
    class WhoToAddController < BaseController
      before_action :initialize_wizard

    private

      def wizard_class
        WhoToAddWizard
      end

      def default_form_step
        "participant-type"
      end
    end
  end
end
