# frozen_string_literal: true

module Withdrawn
  class NPQValidator < BaseValidator
    class << self
      def reasons
        %w[
          left-teaching-profession
          moved-school
          career-break
          other
        ].freeze
      end
    end
  end
end
