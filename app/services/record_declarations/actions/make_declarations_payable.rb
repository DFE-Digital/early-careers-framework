# frozen_string_literal: true

module RecordDeclarations
  module Actions
    class MakeDeclarationsPayable
      class << self
        def call(start_date: "2021-09-01 00:00:00", end_date: "2021-11-01 00:00:00")
          new.call(start_date: start_date, end_date: end_date)
        end
      end

      def call(start_date:, end_date:)
        ParticipantDeclaration::ECF.eligible.declared_as_between(start_date, end_date).submitted_between(start_date, end_date).each(&:make_payable!)
      end
    end
  end
end
