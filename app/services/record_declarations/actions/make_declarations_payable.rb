# frozen_string_literal: true

module RecordDeclarations
  module Actions
    class MakeDeclarationsPayable
      class << self
        def call(declaration_class:, start_date: "2021-09-01 00:00:00", end_date: "2021-11-01 00:00:00")
          new.call(declaration_class: declaration_class, start_date: start_date, end_date: end_date)
        end
      end

      def call(declaration_class:, start_date:, end_date:)
        declaration_class.eligible.declared_as_between(start_date, end_date).submitted_between(start_date, end_date).in_batches do |participant_declarations_group|
          participant_declarations_group.each(&:make_payable!)
        end
      end
    end
  end
end
