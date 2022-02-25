# frozen_string_literal: true

require "csv"

class Exporters::CallOffContracts < BaseService
  def call
    csv_string = CSV.generate do |csv|
      csv << headers

      CallOffContract.all.each do |contract|
        csv << [
          contract.version,
          contract.uplift_target,
          contract.uplift_amount,
          contract.recruitment_target,
          contract.set_up_fee,
          contract.revised_target,
          contract.lead_provider.name,
        ]
      end
    end

    puts csv_string
  end

private

  def headers
    %w[
      version
      uplift_target
      uplift_amount
      recruitment_target
      set_up_fee
      revised_target
      lead_provider_name
    ]
  end
end
