# frozen_string_literal: true

module Finance
  class ClawbackDeclaration
    include ActiveModel::Validations

    validate :validate_not_already_refunded
    validate :validate_refundable_state
    validate :output_fee_statement_available

    def initialize(participant_declaration, voided_by_user:)
      self.participant_declaration = participant_declaration
      self.voided_by_user = voided_by_user
    end

    def call
      return if invalid?

      ApplicationRecord.transaction do
        track_voiding_user
        DeclarationState.awaiting_clawback!(participant_declaration)
        DeclarationStatementAttacher.new(participant_declaration).call
        ParticipantDeclarations::HandleMentorCompletion.call(participant_declaration:)
      end
    end

  private

    attr_accessor :participant_declaration, :voided_by_user

    def track_voiding_user
      return unless voided_by_user

      participant_declaration.update!(voided_by_user:, voided_at: Time.zone.now)
    end

    def output_fee_statement_available
      cohort = participant_declaration.cohort
      cpd_lead_provider = participant_declaration.cpd_lead_provider
      next_output_fee_statement = cpd_lead_provider.lead_provider.next_output_fee_statement(cohort)

      errors.add(:participant_declaration, I18n.t(:no_output_fee_statements_for_cohort, cohort: cohort.start_year)) if next_output_fee_statement.blank?
    end

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
