# frozen_string_literal: true

module Archive
  class ParticipantProfileStateSerializer
    include JSONAPI::Serializer

    set_id :id

    attribute :participant_profile_id
    attribute :cpd_lead_provider_id
    attribute :state
    attribute :reason
    attribute :created_at
  end
end
