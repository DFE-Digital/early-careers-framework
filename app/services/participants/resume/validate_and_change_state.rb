# frozen_string_literal: true

module Participants
  module Resume
    module ValidateAndChangeState
      def perform_action!
        ActiveRecord::Base.transaction do
          user_profile.training_status_active!
          relevant_induction_record.update!(training_status: "active") if relevant_induction_record
        end

        user_profile
      end
    end
  end
end
