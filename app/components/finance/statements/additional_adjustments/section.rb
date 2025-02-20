# frozen_string_literal: true

module Finance
  module Statements
    module AdditionalAdjustments
      class Section < BaseComponent
        attr_accessor :statement

        def initialize(statement:)
          @statement = statement
        end
      end
    end
  end
end
