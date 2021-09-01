# frozen_string_literal: true

module Participants
  module Actions
    class Defer < Base
      class << self
        def recorder_namespace
          "::Participants::Defer"
        end
      end
    end
  end
end
