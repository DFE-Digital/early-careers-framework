# frozen_string_literal: true

module DataArchive
  class ParticipantProfileStateSerializer
    include JSONAPI::Serializer

    set_id :id

    meta do |state|
      {
        lead_provider: state.cpd_lead_provider&.name,
      }
    end

    attribute :participant_profile_id
    attribute :cpd_lead_provider_id
    attribute :state
    attribute :reason
    attribute :created_at
  end
end
