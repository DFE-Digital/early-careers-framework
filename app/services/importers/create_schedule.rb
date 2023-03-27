# frozen_string_literal: true

require "csv"

module Importers
  class CreateSchedule
    attr_reader :path_to_csv

    def initialize(path_to_csv:)
      @path_to_csv = path_to_csv
    end

    def call
      ActiveRecord::Base.transaction do
        rows.each do |row|
          klass = type_to_klass(row["type"])
          cohort = Cohort.find_by!(start_year: row["schedule-cohort-year"].to_i)

          schedule = klass.find_or_initialize_by(
            schedule_identifier: row["schedule-identifier"],
            cohort:,
          )

          schedule.update!(
            name: row["schedule-name"],
          )

          milestone = schedule.milestones.find_or_create_by!(
            name: row["milestone-name"],
            start_date: row["milestone-start-date"],
            milestone_date: row["milestone-date"],
            payment_date: row["milestone-payment-date"],
            declaration_type: row["milestone-declaration-type"],
          )

          schedule.schedule_milestones.find_or_create_by!(
            declaration_type: row["milestone-declaration-type"],
            name: row["milestone-name"],
            milestone:,
          )
        end
      end
    end

  private

    def type_to_klass(type)
      case type
      when "npq_specialist"
        Finance::Schedule::NPQSpecialist
      when "npq_leadership"
        Finance::Schedule::NPQLeadership
      when "npq_aso"
        Finance::Schedule::NPQSupport
      when "npq_ehco"
        Finance::Schedule::NPQEhco
      when "ecf_standard", "ecf_reduced", "ecf_extended"
        Finance::Schedule::ECF
      when "ecf_replacement"
        Finance::Schedule::Mentor
      else
        raise ArgumentError, "Invalid schedule type"
      end
    end

    def rows
      @rows ||= CSV.read(
        path_to_csv,
        headers: true,
        skip_blanks: true,
      )
    end
  end
end
