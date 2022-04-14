# frozen_string_literal: true

module Participants
  module Defer
    module ValidateAndChangeState
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :reason

        validates :reason, inclusion: { in: reasons }
      end

      def perform_action!
        ActiveRecord::Base.transaction do
          user_profile.training_status_deferred!

          relevant_induction_record.update!(training_status: "deferred") if relevant_induction_record
        end

        user_profile
      end
    end
  end
end
