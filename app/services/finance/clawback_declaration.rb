# frozen_string_literal: true

module Finance
  class ClawbackDeclaration
    include ActiveModel::Validations

    attr_reader :participant_declaration

    validate :validate_not_already_refunded
    validate :validate_refundable_state

    def initialize(participant_declaration:)
      @participant_declaration = participant_declaration
    end

    def call
      return if invalid?

      ApplicationRecord.transaction do
        participant_declaration.update!(state: "awaiting_clawback")

        DeclarationStatementAttacher.new(participant_declaration:).call
      end
    end

  private

    def validate_not_already_refunded
      if Finance::StatementLineItem
        .where(participant_declaration:)
        .refundable
        .exists?
        errors.add(:participant_declaration, "will or has been be refunded")
      end
    end

    def validate_refundable_state
      unless %w[paid].include?(participant_declaration.state)
        errors.add(:participant_declaration, "must be paid before it can be clawed back")
      end
    end
  end
end
