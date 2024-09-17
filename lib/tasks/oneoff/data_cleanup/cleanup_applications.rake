# frozen_string_literal: true

require "rake"

namespace :data_cleanup do
  # Accepts a CSV of application IDs (without a header row) and a dry run
  # flag. If the dry run flag is true, the changes will not be performed
  # but the changes that would be made will be logged. Set dry run to false
  # to commit the changes.
  #
  # Example usage (dry run):
  # bundle exec rake 'npq_applications:bulk_change_to_pending[applications.csv,true]'
  #
  # Example usage (perform change):
  # bundle exec rake 'npq_applications:bulk_change_to_pending[applications.csv,false]'
  desc "Data Cleanup - Cleanup Application that exist in ECF not NPQ"
  task :fix_applications_in_ecf_not_in_npq, %i[file dry_run] => :environment do |_task, args|
    logger = Logger.new($stdout)
    csv_file_path = args[:file]
    dry_run = args[:dry_run] != "false"

    unless File.exist?(csv_file_path)
      logger.error "File not found: #{csv_file_path}"
      return
    end

    npq_application_ids = CSV.read(csv_file_path, headers: false).flatten

    logger.info "Fixing #{npq_application_ids.size} NPQ applications not in NPQ#{' (dry run)' if dry_run}..."

    result = Oneoffs::NPQ::DataCleanup::FixApplicationsInECFNotInNPQ.new(npq_application_ids:).run!(dry_run:)

    logger.info JSON.pretty_generate(result)
  end
end
