# frozen_string_literal: true

module Deferral
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
