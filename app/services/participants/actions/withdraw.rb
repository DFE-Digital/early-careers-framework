# frozen_string_literal: true

module Participants
  module Actions
    class Withdraw < Base
      class << self
        def recorder_namespace
          "::Participants::Withdraw"
        end
      end
    end
  end
end
