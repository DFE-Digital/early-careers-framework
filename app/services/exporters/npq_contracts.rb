# frozen_string_literal: true

require "csv"

class Exporters::NPQContracts < BaseService
  def call
    csv_string = CSV.generate do |csv|
      csv << headers

      NPQContract.includes(:npq_lead_provider).each do |contract|
        csv << [
          contract.version,
          contract.npq_lead_provider.name,
          contract.recruitment_target,
          contract.course_identifier,
          contract.service_fee_installments,
          contract.service_fee_percentage,
          contract.per_participant,
          contract.number_of_payment_periods,
          contract.output_payment_percentage,
        ]
      end
    end

    puts csv_string
  end

private

  def headers
    %w[
      version
      npq_lead_provider_name
      recruitment_target
      course_identifier
      service_fee_installments
      service_fee_percentage
      per_participant
      number_of_payment_periods
      output_payment_percentage
    ]
  end
end
