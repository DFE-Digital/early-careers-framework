# frozen_string_literal: true

module Participants
  module Withdraw
    class NPQ < Base
      class << self
        def reasons
          %w[
            insufficient-capacity-to-undertake-programme
            personal-reason-health-or-pregnancy-related
            personal-reason-moving-school
            personal-reason-other
            insufficient-capacity
            change-in-developmental-or-personal-priorities
            change-in-school-circumstances
            change-in-school-leadership
            quality-of-programme-structure-not-suitable.
            quality-of-programme-content-not-suitable
            quality-of-programme-facilitation-not-effective
            quality-of-programme-accessibility
            quality-of-programme-other
            programme-not-appropriate-for-role-and-cpd-needs
            other
          ].freeze
        end
      end

      include Participants::NPQ
      include ValidateAndChangeState
    end
  end
end
