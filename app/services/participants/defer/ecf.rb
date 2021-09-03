# frozen_string_literal: true

module Participants
  module Defer
    class ECF < ::Participants::Base
      class << self
        def reasons
          %w[
            left-teaching-profession
            moved-school
            mentor-no-longer-being-mentor
            school-left-fip
            career-break
            passed-induction
            other
          ].freeze
        end
      end

      include Participants::ECF
      include ValidateAndChange
    end
  end
end
