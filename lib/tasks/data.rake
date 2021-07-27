# frozen_string_literal: true

namespace :data do
  desc "Populates all missing ParticipantProfiles::NPQ to match NPQProfile table"
  task populate_teacher_profiles: :environment do
    ParticipantProfile.where(teacher_profile_id: nil).each(&:save!)
  end
end
