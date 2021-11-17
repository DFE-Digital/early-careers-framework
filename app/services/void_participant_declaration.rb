# frozen_string_literal: true

class VoidParticipantDeclaration
  attr_accessor :cpd_lead_provider, :id

  def call
    declaration = ParticipantDeclaration.for_lead_provider(cpd_lead_provider).find(id)

    raise Api::Errors::InvalidTransitionError, I18n.t(:declaration_already_voided) if declaration.voided?

    latest_declaration = declaration.participant_profile.participant_declarations.order(declaration_date: :desc).first
    raise Api::Errors::InvalidTransitionError, I18n.t(:void_last_declaration_only) if latest_declaration != declaration

    declaration.voided!
    ParticipantDeclarationSerializer.new(declaration).serializable_hash.to_json
  end

private

  def initialize(cpd_lead_provider:, id:)
    @cpd_lead_provider = cpd_lead_provider
    @id = id
  end
end
