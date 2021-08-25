# frozen_string_literal: true

class Importers::NPQManualValidation
  attr_reader :path_to_csv

  def initialize(path_to_csv:)
    @path_to_csv = path_to_csv
  end

  def call
    check_headers

    rows.each do |row|
      data = NPQValidationData.find_by(id: row["application_ecf_id"])

      puts "no NPQValidationData found for #{row['application_ecf_id']}" if data.nil?
      next if data.nil?

      puts "updating trn for NPQValidationData: #{row['application_ecf_id']} with trn: #{row['validated_trn']}"

      ApplicationRecord.transaction do
        data.update!(teacher_reference_number: row["validated_trn"], teacher_reference_number_verified: true)
        NPQ::CreateOrUpdateProfile.new(npq_validation_data: data).call
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
