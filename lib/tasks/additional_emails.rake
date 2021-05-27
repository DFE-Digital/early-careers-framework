# frozen_string_literal: true

require "rake"

namespace :additional_emails do
  desc "Import additional school emails from CSV"
  task import: :environment do
    logger = Logger.new($stdout)
    logger.info "Importing additional school emails, this may take a couple of minutes..."
    AdditionalEmailImporter.new(logger).run
    logger.info "Additional school email import complete!"
    logger.info "Additional email count: #{AdditionalSchoolEmail.count}"
  end
end
