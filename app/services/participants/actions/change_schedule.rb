# frozen_string_literal: true

module Participants
  module Actions
    class ChangeSchedule < Base
      class << self
        def recorder_namespace
          "::Participants::ChangeSchedule"
        end
      end
    end
  end
end
