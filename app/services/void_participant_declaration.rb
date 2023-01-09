# frozen_string_literal: true

class VoidParticipantDeclaration
  def initialize(participant_declaration)
    self.participant_declaration = participant_declaration
  end

  def call
    if participant_declaration.paid?
      make_awaiting_clawback
    else
      make_voided
    end

    NPQ::VoidParticipantOutcome.new(participant_declaration).call

    participant_declaration
  end

  def make_awaiting_clawback
    clawback = Finance::ClawbackDeclaration.new(participant_declaration)
    clawback.call

    if clawback.errors.any?
      raise Api::Errors::InvalidTransitionError, clawback.errors.full_messages.join(", ")
    end
  end

  def make_voided
    # TODO: these should be moved to activemodel validations
    # and not controller level exceptions
    raise Api::Errors::InvalidTransitionError, I18n.t(:declaration_already_voided) if participant_declaration.voided?
    raise Api::Errors::InvalidTransitionError, I18n.t(:declaration_not_voidable) unless participant_declaration.voidable?

    ApplicationRecord.transaction do
      participant_declaration.make_voided!
      line_item.voided! if line_item
    end
  end

private

  attr_accessor :participant_declaration

  def line_item
    participant_declaration.statement_line_items.find_by(state: %w[eligible payable submitted])
  end
end
