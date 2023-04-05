# frozen_string_literal: true

class Importers::NPQManualValidation
  attr_reader :path_to_csv

  def initialize(path_to_csv:)
    @path_to_csv = path_to_csv
  end

  def call
    check_headers

    rows.each do |row|
      npq_application_id = row["application_ecf_id"]
      trn = row["validated_trn"]

      npq_application = NPQApplication.find_by(id: npq_application_id)

      puts "No NPQApplication found for #{npq_application_id}" if npq_application.nil?
      next if npq_application.nil?

      puts "Updating TRN for NPQApplication: #{npq_application_id} with TRN: #{trn}"
      npq_application.update!(teacher_reference_number: row["validated_trn"], teacher_reference_number_verified: true)

      teacher_profile = npq_application.profile.try(:teacher_profile)
      next if teacher_profile.nil?

      puts "Updating TeacherProfile for NPQApplication: #{npq_application_id} with TRN: #{trn}"
      teacher_profile.update!(trn:)
    end
  end

private

  def check_headers
    unless rows.headers == %w[application_ecf_id validated_trn]
      raise NameError, "Invalid headers"
    end
  end

  def rows
    @rows ||= CSV.read(path_to_csv, headers: true)
  end
end
