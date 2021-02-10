# frozen_string_literal: true

require "rake"

namespace :schools_data do
  desc "Import schools data from Get Information About Schools"
  task import: :environment do
    logger = Logger.new($stdout)
    logger.info "Importing schools data, this may take a couple minutes..."
    SchoolDataImporter.new(logger).run
    logger.info "Schools data import complete!"
  end
end
