# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      module Analysis
        class Table < BaseComponent
          def initialize(applications:)
            @applications = applications
          end

        private

          attr_reader :applications
        end
      end
    end
  end
end
