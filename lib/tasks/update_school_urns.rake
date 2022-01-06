# frozen_string_literal: true

require "rake"

namespace :update_school_urns do
  desc "Copy school_urn from NPQ Application to participant profile if missing from record"
  task one_off: :environment do
    PaperTrail.request.controller_info = {
      reason: "CPDLP-843 - update-urn-if-missing-on-profile",
    }

    records_to_update = ParticipantProfile::NPQ.where(school_urn: nil).joins(:npq_application).where.not(npq_applications: { school_urn: nil })
    puts "#{records_to_update.count} records to update"
    puts "#{records_to_update.map(&:id)} records to update"

    records_to_update.find_each do |profile|
      profile.school_urn = profile.npq_application.school_urn
      profile.save!
    end

    puts "#{records_to_update.count} failed to update"
    puts "#{records_to_update.map(&:id)} failed to update"
  end
end
