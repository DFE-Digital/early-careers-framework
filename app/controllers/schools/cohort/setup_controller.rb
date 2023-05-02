# frozen_string_literal: true

module Schools
  module Cohort
    class SetupController < BaseController
      skip_before_action :redirect_to_setup_current_cohort

      def default_step_name
        :what_we_need
      end

    private

      def wizard_class
        SetupWizard
      end
    end
  end
end
