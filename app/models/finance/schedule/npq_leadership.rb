# frozen_string_literal: true
require "finance/schedule"

module Finance
  class Schedule < ApplicationRecord
    class NPQLeadership < Schedule
      IDENTIFIERS = %w[
        npq-senior-leadership
        npq-headship
        npq-executive-leadership
      ].freeze

      def self.default
        find_by(name: "NPQ Leadership November 2021")
      end
    end
  end
end
