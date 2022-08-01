# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      module Analysis
        class TableRow < BaseComponent
          with_collection_parameter :application

          def initialize(application:)
            @application = application
          end

        private

          attr_reader :application
        end
      end
    end
  end
end
