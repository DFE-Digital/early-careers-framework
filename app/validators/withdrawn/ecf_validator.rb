# frozen_string_literal: true

module Withdrawn
  class ECFValidator < BaseValidator
    class << self
      def reasons
        %w[left-teaching-profession moved-school mentor-no-longer-being-mentor school-left-fip career-break passed-induction other].freeze
      end
    end
  end
end
