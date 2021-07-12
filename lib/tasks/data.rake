# frozen_string_literal: true

namespace :data do
  desc "Populates all missing ParticipantProfiles::NPQ to match NPQProfile table"
  task populate_npq_profiles: :environment do
    NPQProfile.where.not(id: ParticipantProfile::NPQ.select(:id)).find_each do |profile|
      profile.send(:update_participant_profile)
    end
  end
end
