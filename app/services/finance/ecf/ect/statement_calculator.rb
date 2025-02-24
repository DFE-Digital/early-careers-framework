# frozen_string_literal: true

require "payment_calculator/ecf/service_fees"

module Finance
  module ECF
    module ECT
      class StatementCalculator < Finance::ECF::StatementCalculator
        def voided_declarations
          statement.participant_declarations.voided.merge!(ParticipantDeclaration.ect)
        end

        def ect?
          true
        end
      end
    end
  end
end
