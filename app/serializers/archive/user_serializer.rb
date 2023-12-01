# frozen_string_literal: true

module Archive
  class UserSerializer
    include JSONAPI::Serializer
    include ArchiveHelper

    set_id :id

    attribute :email
    attribute :full_name
    attribute :created_at

    # values to search on (this is indexed)
    meta do |user|
      add_user_metadata(user)
    end

    attribute :teacher_profile do |user|
      TeacherProfileSerializer.new(user.teacher_profile).serializable_hash[:data]
    end

    attribute :participant_identities do |user|
      ParticipantIdentitySerializer.new(user.participant_identities).serializable_hash[:data]
    end

    attribute :participant_profiles do |user|
      ParticipantProfileSerializer.new(user.participant_profiles).serializable_hash[:data]
    end

    attribute :npq_applications do |user|
      NPQApplicationSerializer.new(user.npq_applications).serializable_hash[:data]
    end
  end
end
