# frozen_string_literal: true

# This Rake task is designed for a single execution to update verified data for users and applications
# based on data provided in a CSV file. The full file path of the CSV is passed as a parameter to the task.
#
# The task reads each row from the CSV file, finds the corresponding application and its associated user,
# and updates them with the verified data. The task is intended to be run once and can be safely removed
# after its execution. The code is deliberately not DRY to ensure it is explicit and clear to the reader.
#
# Usage:
# Run this task from the command line in your Rails application directory using:
# `rake oneoff:update_verified_data['/path/to/your/file.csv']`
#
# The task logs detailed information about the processing, including any warnings or errors encountered.
# It ensures that failure to update one record does not halt the entire process, allowing all records
# in the CSV file to be processed.

namespace :oneoff do
  desc "Update verified data for users and applications"
  task :update_verified_data, [:file_path] => :environment do |_t, args|
    require "csv"
    require "logger"

    logger = Logger.new($stdout)
    filename = args[:file_path]

    CSV.foreach(filename, headers: true) do |row|
      application = NPQApplication.find_by(id: row["application_ecf_id"])

      unless application
        logger.warn("Application not found: #{row['application_ecf_id']}")
        next
      end

      user = application.user
      unless user
        logger.warn("User not found for application: #{application.id}")
        next
      end

      # Gather verified data
      verified_data = {
        full_name: row["Name verified"],
        dob: row["DoB verified"],
        email: row["email verified"],
        nino: row["NINO verified"],
      }

      missing_data = verified_data
                       .reject { |k, _| k == :nino }
                       .select { |_, v| v.blank? }
                       .keys

      if missing_data.any?
        logger.warn("Missing verified data for user: #{user.id}, application: #{application.id}. Missing fields: #{missing_data.join(', ')}")
      else
        ActiveRecord::Base.transaction do
          user.update!(
            full_name: verified_data[:full_name],
          )
          application.update!(
            date_of_birth: verified_data[:dob],
            nino: verified_data[:nino],
            teacher_reference_number: row["TRN verified"],
            teacher_reference_number_verified: true,
          )

          teacher_profile = application.profile&.teacher_profile
          teacher_profile && teacher_profile.update!(trn: row["TRN verified"])

          logger.info "Application: #{application.id} updated verified data with TRN: #{row['TRN verified']}"
        rescue StandardError => e
          logger.error("Failed to update user: #{user.id} or application: #{application.id}. Error: #{e.message}")
        end
      end
    end
  end
end
