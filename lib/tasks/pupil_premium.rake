# frozen_string_literal: true

require "rake"

namespace :pupil_premium do
  desc "Import pupil premium data from CSV"
  task import: :environment do
    logger = Logger.new($stdout)
    logger.info "Importing pupil premium data, this may take a couple minutes..."
    PupilPremiumImporter.new(logger).run
    logger.info "Pupil premium data import complete!"
  end

  desc "Update cached pupil premium uplift on participant profiles"
  task update_cached_pupil_premium_uplift: :environment do
    logger = Logger.new($stdout)
    logger.info "Updating cached pupil premium data..."
    ParticipantProfile.find_each do |participant_profile|
      pupil_premium_uplift = participant_profile&.school&.pupil_premium_uplift?(Time.zone.now.year) || false
      participant_profile.update!(pupil_premium_uplift: pupil_premium_uplift)
    end
    logger.info "Done."
  end
end
