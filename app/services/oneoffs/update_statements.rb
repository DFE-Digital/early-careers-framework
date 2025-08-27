# frozen_string_literal: true

require "csv"

module Oneoffs
  class UpdateStatements
    include HasRecordableInformation

    def initialize(path_to_csv:)
      @path_to_csv = path_to_csv
    end

    def perform_change(dry_run: true)
      reset_recorded_info

      check_headers!

      record_info("~~~ DRY RUN ~~~") if dry_run

      ActiveRecord::Base.transaction do
        rows.each do |row|
          record_info("Looking at statements for cohort: #{row['cohort']} and name: #{row['name']}")

          statement_data = build_statement_data(row)
          update_statements(statement_data:)
        end

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

  private

    def update_statements(statement_data:)
      cohort = statement_data[:cohort]
      name = statement_data[:name]

      statements = Finance::Statement::ECF.where(
        cohort:,
        name:,
      )

      if statements.none?
        record_info "No statements found for cohort: #{cohort.start_year} with name: #{name}"
        return
      end

      statements.each do |statement|
        update_statement!(statement:, statement_data:)
      end
    end

    def update_statement!(statement:, statement_data:)
      statement.deadline_date = statement_data[:deadline_date]
      statement.payment_date = statement_data[:payment_date]
      statement.output_fee = statement_data[:output_fee]

      if statement.has_changes_to_save?
        record_info "Updating statement: '#{statement.id}' with changes: #{statement.changes_to_save.inspect}"
        statement.save!
      else
        record_info "No updates made to statement: '#{statement.id}' with cohort: #{statement.cohort.start_year} and name: #{statement.name}"
      end
    end

    def check_headers!
      unless %w[type name cohort deadline_date payment_date output_fee].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid CSV headers"
      end
    end

    def rows
      @rows ||= CSV.read(@path_to_csv, headers: true)
    end

    def build_statement_data(row)
      {
        name: row["name"],
        cohort: Cohort.find_by!(start_year: row["cohort"]),
        deadline_date: Date.parse(row["deadline_date"]),
        payment_date: Date.parse(row["payment_date"]),
        output_fee: ActiveModel::Type::Boolean.new.cast(row["output_fee"]),
      }
    end
  end
end
