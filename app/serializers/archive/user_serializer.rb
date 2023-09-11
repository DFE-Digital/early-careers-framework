# frozen_string_literal: true

module Archive
  class UserSerializer
    include JSONAPI::Serializer

    set_id :id

    attribute :email
    attribute :full_name

    # values to search on (this is indexed)
    meta do |user|
      [
        user.id,
        user.full_name,
        user.email,
        user.teacher_profile&.trn,
      ].compact
    end

    # teacher_profile
    attribute :teacher_profile do |user|
      TeacherProfileSerializer.new(user.teacher_profile).serializable_hash[:data]
    end

    # participant identities -> participant profiles -> induction records
    attribute :participant_identities do |user|
      ParticipantIdentitySerializer.new(user.participant_identities).serializable_hash[:data]
    end

    attribute :participant_profiles do |user|
      ParticipantProfileSerializer.new(user.participant_profiles).serializable_hash[:data]
    end

    attribute :induction_records do |user|
      user.participant_profiles.map { |participant_profile|
        InductionRecordSerializer.new(participant_profile.induction_records).serializable_hash[:data]
      }.flatten
    end

    attribute :participant_declarations do |user|
      user.participant_profiles.map { |participant_profile|
        ParticipantDeclarationSerializer.new(participant_profile.participant_declarations).serializable_hash[:data]
      }.flatten
    end

    attribute :participant_profile_states do |user|
      user.participant_profiles.map { |participant_profile|
        ParticipantProfileStateSerializer.new(participant_profile.participant_profile_states).serializable_hash[:data]
      }.flatten
    end

    attribute :participant_profile_schedules do |user|
      user.participant_profiles.map { |participant_profile|
        ParticipantProfileScheduleSerializer.new(participant_profile.participant_profile_schedules).serializable_hash[:data]
      }.flatten
    end

    attribute :npq_applications do |user|
      NPQApplicationSerializer.new(user.npq_applications).serializable_hash[:data]
    end
  end
end
