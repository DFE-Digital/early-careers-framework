# frozen_string_literal: true

module Archive
  class ParticipantProfileScheduleSerializer
    include JSONAPI::Serializer

    set_id :id

    meta do |schedule|
      {
        schedule_name: schedule.name,
        cohort: schedule.cohort.start_year,
      }
    end

    attribute :participant_profile_id
    attribute :schedule_id
    attribute :created_at
  end
end
