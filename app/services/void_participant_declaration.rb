# frozen_string_literal: true

class VoidParticipantDeclaration
  attr_accessor :cpd_lead_provider, :id

  def initialize(cpd_lead_provider:, id:)
    @cpd_lead_provider = cpd_lead_provider
    @id = id
  end

  def call
    # TODO: these should be moved to activemodel validations
    # and not controller level exceptions
    raise Api::Errors::InvalidTransitionError, I18n.t(:declaration_already_voided) if declaration.voided?
    raise Api::Errors::InvalidTransitionError, I18n.t(:declaration_not_voidable) unless declaration.voidable?

    declaration.make_voided!

    ParticipantDeclarationSerializer.new(declaration).serializable_hash.to_json
  end

private

  def declaration
    @declaration ||= ParticipantDeclaration.for_lead_provider(cpd_lead_provider).find(id)
  end
end
