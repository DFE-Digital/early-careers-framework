# frozen_string_literal: true

module Mail
  module Notify
    class Personalisation
      BLANK = Object.new

      module BlankFix
        def to_h
          super.transform_values do |value|
            value == BLANK ? "" : value
          end
        end
      end

      prepend BlankFix
    end
  end
end
