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
end
