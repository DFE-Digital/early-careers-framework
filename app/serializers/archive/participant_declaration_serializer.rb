# frozen_string_literal: true

module Archive
  class ParticipantDeclarationSerializer
    include JSONAPI::Serializer

    set_id :id

    meta do |declaration|
      {
        lead_provider: declaration.cpd_lead_provider&.name,
        delivery_partner: declaration.delivery_partner&.name,
      }
    end

    attribute :type
    attribute :participant_profile_id
    attribute :cpd_lead_provider_id
    attribute :declaration_type
    attribute :declaration_date
    attribute :course_identifier
    attribute :user_id
    attribute :evidence_held
    attribute :state
    attribute :sparsity_uplift
    attribute :pupil_premium_uplift
    attribute :superseded_by
    attribute :delivery_partner_id
    attribute :mentor_user_id
    attribute :created_at
  end
end
