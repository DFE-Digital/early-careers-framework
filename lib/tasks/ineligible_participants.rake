# frozen_string_literal: true

require "rake"

namespace :ineligible_participants do
  desc "Import ineligible participants from CSV"
  task :import, %i[csv_path reason] => :environment do |_t, args|
    logger = Logger.new($stdout)
    logger.info "Importing ineligible participants, this may take a couple minutes..."
    Importers::IneligibleParticipants.call(path_to_csv: args.csv_path, reason: args.reason, logger: logger)
    logger.info "Ineligible participant data import complete!"
  end
end
