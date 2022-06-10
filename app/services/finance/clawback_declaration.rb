# frozen_string_literal: true

module Finance
  class ClawbackDeclaration
    include ActiveModel::Validations

    validate :validate_not_already_refunded
    validate :validate_refundable_state

    def initialize(participant_declaration)
      self.participant_declaration = participant_declaration
    end

    def call
      return if invalid?

      ApplicationRecord.transaction do
        DeclarationState.awaiting_clawback!(participant_declaration)
        DeclarationStatementAttacher.new(participant_declaration).call
      end
    end

  private

    attr_accessor :participant_declaration

    def validate_not_already_refunded
      return unless participant_declaration.statement_line_items.refundable.exists?

      errors.add(:participant_declaration, "will or has been be refunded")
    end

    def validate_refundable_state
      unless %w[paid].include?(participant_declaration.state)
        errors.add(:participant_declaration, "must be paid before it can be clawed back")
      end
    end
  end
end
