# frozen_string_literal: true

require "payment_calculator/ecf/service_fees"

module Finance
  module ECF
    module ECT
      class StatementCalculator < Finance::ECF::StatementCalculator
        def clawed_back_declarations
          statement.participant_declarations.clawed_back.merge!(ParticipantDeclaration.ect)
        end

        def voided_declarations
          statement.participant_declarations.voided.merge!(ParticipantDeclaration.ect)
        end

        def ect?
          true
        end

      private

        def output_calculator
          @output_calculator ||= OutputCalculator.new(statement:)
        end
      end
    end
  end
end
