# frozen_string_literal: true

class Importers::NPQManualValidation
  attr_reader :path_to_csv

  def initialize(path_to_csv:)
    @path_to_csv = path_to_csv
  end

  def call
    check_headers

    rows.each do |row|
      data = NPQApplication.find_by(id: row["application_ecf_id"])

      puts "no NPQApplication found for #{row['application_ecf_id']}" if data.nil?
      next if data.nil?

      puts "updating trn for NPQApplication: #{row['application_ecf_id']} with trn: #{row['validated_trn']}"

      ApplicationRecord.transaction do
        data.update!(teacher_reference_number: row["validated_trn"], teacher_reference_number_verified: true)
        teacher_profile = data.user.teacher_profile
        teacher_profile.update!(trn: row["validated_trn"])
      end
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
