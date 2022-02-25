# frozen_string_literal: true

class Importers::CallOffContracts
  attr_reader :path_to_csv

  def initialize(path_to_csv:)
    @path_to_csv = path_to_csv
  end

  def call
    check_headers

    rows.each do |row|
      lead_provider = LeadProvider.find_by!(name: row["lead_provider_name"])

      contract = CallOffContract.find_or_create_by!(
        version: row["version"],
        lead_provider: lead_provider,
      )

      contract.update!(
        uplift_target: row["uplift_target"],
        uplift_amount: row["uplift_amount"],
        recruitment_target: row["recruitment_target"],
        set_up_fee: row["set_up_fee"],
        revised_target: row["revised_target"],
      )
    end
  end

private

  def check_headers
    unless rows.headers == Exporters::CallOffContracts.new.send(:headers)
      raise NameError, "Invalid headers"
    end
  end

  def rows
    @rows ||= CSV.read(path_to_csv, headers: true)
  end
end
