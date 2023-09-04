# frozen_string_literal: true

module DataArchive
  class ParticipantIdentitySerializer
    include JSONAPI::Serializer

    set_id :id

    attribute :email
    attribute :external_identifier
    attribute :origin
    attribute :created_at

    # not going to serialize the complete profiles here
    attribute :participant_profiles do |participant_identity|
      participant_identity.participant_profiles.map do |participant_profile|
        {
          id: participant_profile.id,
          type: participant_profile.type,
        }
      end
    end
  end
end
