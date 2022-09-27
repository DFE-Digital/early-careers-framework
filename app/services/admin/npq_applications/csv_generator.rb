# frozen_string_literal: true

require "csv"

module Admin
  module NPQApplications
    class CsvGenerator
      CSV_EXPORT_COLUMNS = [
        :id,
        :cohort_start_year,
        :npq_course_id,
        :npq_lead_provider_id,
        :npq_course_name,
        :npq_lead_provider_name,
        :teacher_catchment, # Not currently sent to ECF from NPQ
        :teacher_catchment_country, # Not currently sent to ECF from NPQ
        :works_in_school,
        :works_in_childcare,
        :works_in_nursery,
        :kind_of_nursery,
        :headteacher_status,
        :school_urn,
        :private_childcare_provider_urn,
        :school_ukprn,
        :eligible_for_funding,
        :funding_eligiblity_status_code,
        :funding_choice,
        :employer_name,
        :employment_role,
        :employment_type,
        :targeted_delivery_funding_eligibility,
        :created_at,
        :user_id,
        :user_email,
        :user_full_name,
        :teacher_reference_number_verified,
        :teacher_reference_number, # Possibly not needed
      ].freeze

      attr_reader :start_date, :end_date

      def initialize(start_date:, end_date:)
        @start_date = start_date.at_beginning_of_day
        @end_date = end_date.at_end_of_day
      end

      def csv
        CSV.generate do |csv|
          csv << CSV_EXPORT_COLUMNS

          applications.find_each do |application|
            csv_row_data = CSV_EXPORT_COLUMNS.map { |csv_column| application.send(csv_column) }

            csv << csv_row_data
          end
        end
      end

    private

      def applications
        @applications ||= NPQApplication.where(created_at: start_date..end_date)
      end
    end
  end
end
