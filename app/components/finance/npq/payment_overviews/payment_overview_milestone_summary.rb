# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewMilestoneSummary < BaseComponent
        attr_reader :total_participants
        def initialize(milestone, total_participants)
          self.milestone = milestone
          self.total_participants = total_participants
        end

        def declaration_type
          milestone.declaration_type.titleize
        end

      private
        attr_accessor :milestone
        attr_writer :total_participants
      end
    end
  end
end
