# frozen_string_literal: true

module Withdrawn
  class ECFValidator < BaseValidator
    class << self
      def reasons
        [
          "Left teaching profession",
          "Moved school",
          "Mentor no longer being mentor",
          "School left FIP",
          "Career break",
          "Passed Induction",
          "Other",
        ].freeze
      end
    end
  end
end
