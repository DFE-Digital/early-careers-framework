# frozen_string_literal: true

class VoidParticipantDeclaration
  attr_accessor :cpd_lead_provider, :id

  def call
    declaration = ParticipantDeclaration.for_lead_provider(cpd_lead_provider).find(id)

    raise Api::Errors::InvalidTransitionError, "Declaration is already voided" if declaration.voided

    latest_declaration = declaration.participant_profile.participant_declarations.order(declaration_date: :desc).first
    raise Api::Errors::InvalidTransitionError, "Can only void last declaration" if latest_declaration != declaration

    declaration.void!
    ParticipantDeclarationSerializer.new(declaration).serializable_hash.to_json
  end

private

  def initialize(cpd_lead_provider:, id:)
    @cpd_lead_provider = cpd_lead_provider
    @id = id
  end
end
