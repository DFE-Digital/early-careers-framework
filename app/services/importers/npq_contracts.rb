# frozen_string_literal: true

class Importers::NPQContracts
  attr_reader :path_to_csv

  def initialize(path_to_csv:)
    @path_to_csv = path_to_csv
  end

  def call
    check_headers

    rows.each do |row|
      npq_lead_provider = NPQLeadProvider.find_by!(name: row["npq_lead_provider_name"])

      contract = NPQContract.find_or_initialize_by(
        version: row["version"],
        npq_lead_provider: npq_lead_provider,
        course_identifier: row["course_identifier"],
      )

      contract.update!(
        recruitment_target: row["recruitment_target"],
        service_fee_installments: row["service_fee_installments"],
        service_fee_percentage: row["service_fee_percentage"],
        per_participant: row["per_participant"],
        number_of_payment_periods: row["number_of_payment_periods"],
        output_payment_percentage: row["output_payment_percentage"],
      )
    end
  end

private

  def check_headers
    unless rows.headers == Exporters::NPQContracts.new.send(:headers)
      raise NameError, "Invalid headers"
    end
  end

  def rows
    @rows ||= CSV.read(path_to_csv, headers: true)
  end
end
