# frozen_string_literal: true

module RecordDeclarations
  module Actions
    class MakePayableBetween
      include WithMilestone

      def call
        ParticipantDeclaration.eligible.where("declaration_date <= ?", milestone).each(&:make_payable)
      end
    end
  end
end
