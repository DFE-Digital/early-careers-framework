# frozen_string_literal: true

module Finance
  module ECF
    module ECT
      class BandingCalculator < Finance::ECF::BandingCalculator
      private

        def previous_statement_line_items
          super.merge!(ParticipantDeclaration.ect)
        end

        def current_statement_line_items
          super.merge!(ParticipantDeclaration.ect)
        end
      end
    end
  end
end
