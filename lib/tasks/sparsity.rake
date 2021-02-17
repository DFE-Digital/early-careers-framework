# frozen_string_literal: true

require "rake"

namespace :sparsity do
  desc "Import sparsity data from CSV"
  task import: :environment do
    logger = Logger.new($stdout)
    logger.info "Importing sparsity data, this may take a couple minutes..."
    SparsityImporter.new(logger).run
    logger.info "Sparsity data import complete!"
  end
end
