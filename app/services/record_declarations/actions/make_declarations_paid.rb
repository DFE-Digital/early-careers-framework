# frozen_string_literal: true

module RecordDeclarations
  module Actions
    class MakeDeclarationsPaid
      class << self
        delegate :call, to: :new
      end

      def call
        ParticipantDeclaration::ECF.payable.each(&:make_paid!)
      end
    end
  end
end
