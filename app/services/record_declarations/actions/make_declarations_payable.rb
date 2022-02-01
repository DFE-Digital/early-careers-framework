# frozen_string_literal: true

module RecordDeclarations
  module Actions
    class MakeDeclarationsPayable
      class << self
        def call(declaration_class:, cutoff_date:)
          declaration_class.eligible.where("created_at <= ?", cutoff_date).in_batches do |participant_declarations_group|
            participant_declarations_group.each(&:make_payable!)
          end
        end
      end
    end
  end
end
