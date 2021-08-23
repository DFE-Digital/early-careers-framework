# frozen_string_literal: true

module Withdrawn
  class NPQValidator < BaseValidator
    class << self
      def reasons
        [
          "Left teaching profession",
          "Moved school",
          "Career break",
          "Other",
        ].freeze
      end
    end
  end
end
