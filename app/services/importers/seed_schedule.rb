# frozen_string_literal: true

require "csv"

class Importers::SeedSchedule
  attr_reader :path_to_csv, :klass

  def initialize(path_to_csv:, klass:)
    @path_to_csv = path_to_csv
    @klass = klass
  end

  def call
    rows = CSV.read(path_to_csv, headers: true)

    rows.each do |row|
      next unless row["schedule-identifier"]

      year = row["schedule-cohort-year"].to_i
      cohort = Cohort.find_by!(start_year: year)

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

      schedule.schedule_milestones.create!(
        declaration_type: row["milestone-declaration-type"],
        name: row["milestone-name"],
        milestone:,
      )
    end
  end
end
