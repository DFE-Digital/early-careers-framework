# frozen_string_literal: true

namespace :data do
  desc "Populates ParticipantProfile using data from EarlyCareerTeacherProfile and MentorProfile"
  task populate_participant_profiles: :environment do
    MentorProfile.where.not(id: ParticipantProfile.select(:id)).find_in_batches(batch_size: 100) do |batch|
      ParticipantProfile.insert_all(
        batch.map do |mentor_profile|
          {
            type: "ParticipantProfile::Mentor",
            **mentor_profile.attributes.transform_keys(&:to_sym),
          }
        end,
      )
    end

    EarlyCareerTeacherProfile.where.not(id: ParticipantProfile.select(:id)).find_in_batches(batch_size: 100) do |batch|
      ParticipantProfile.insert_all(
        batch.map do |ect_profile|
          {
            type: "ParticipantProfile::ECT",
            **ect_profile.attributes.transform_keys(&:to_sym),
          }
        end,
      )
    end
  end
end
