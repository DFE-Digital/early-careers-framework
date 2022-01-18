# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class ECF < Base
      delegate :school_cohort, to: :user_profile, allow_nil: true

    private

      def matches_lead_provider?
        cpd_lead_provider == school_cohort&.lead_provider&.cpd_lead_provider
      end
    end
  end
end
