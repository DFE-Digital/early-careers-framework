# frozen_string_literal: true

module Finance
  module ECF
    module ECT
      class StatementCalculator < Finance::ECF::StatementCalculator
        def ect?
          true
        end

      private

        def participant_declarations
          super.merge!(ParticipantDeclaration.ect)
        end
      end
    end
  end
end
