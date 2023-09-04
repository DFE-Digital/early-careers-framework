# frozen_string_literal: true

module DataArchive
  class ParticipantProfileScheduleSerializer
    include JSONAPI::Serializer

    set_id :id

    attribute :schedule_name do |object|
      object.schedule.name
    end

    attribute :cohort do |object|
      object.cohort.start_year
    end

    attribute :participant_profile_id
    attribute :schedule_id
    attribute :created_at
  end
end
