# frozen_string_literal: true

module Schools
  module ChangeRequestSupportQuery
    class CheckYourAnswersStep < StoredStep
      attr_accessor :complete

      def self.permitted_params
        [:complete]
      end

      def previous_step
        :relation
      end

      def next_step
        :success
      end
    end
  end
end
