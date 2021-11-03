# frozen_string_literal: true

module Participants
  module Defer
    module DeferralReasons
      def reasons
        %w[
          bereavement
          long-term-sickness
          parental-leave
          career-break
          other
        ].freeze
      end
    end
  end
end
