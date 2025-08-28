# frozen_string_literal: true

# This class provides a mechanism to import genesis statements
# It is not designed to keep statements in sync
# For that should be done by hand
# We only create/update version 0.0.1 for initial values
# Manually create new version of contract if there are changes

require "csv"

module Importers
  class CreateStatement < BaseService
    def call
      check_headers!

      logger.info "CreateStatement: Started!"

      ActiveRecord::Base.transaction do
        create_ecf_statements!
      end

      logger.info "CreateStatement: Finished!"
    end

  private

    attr_reader :path_to_csv, :logger

    def initialize(path_to_csv:, logger: Rails.logger)
      @path_to_csv = path_to_csv
      @logger = logger
    end

    def create_ecf_statements!
      ecf_statements.each do |statement_data|
        lead_providers_with_ecf_contracts_for(cohort: statement_data.cohort).each do |lead_provider|
          cpd_lead_provider = lead_provider.cpd_lead_provider

          logger.info "CreateStatement: Creating #{statement_data.cohort.start_year} cohort ECF statements for #{cpd_lead_provider.name}"

          statement = Finance::Statement::ECF.find_by(
            name: statement_data.name,
            cpd_lead_provider:,
            cohort: statement_data.cohort,
          )

          next if statement

          latest_statement = Finance::Statement::ECF.where(cpd_lead_provider:, cohort: statement_data.cohort).order(payment_date: :desc).first

          contract_version = latest_statement&.contract_version
          contract_version ||= "0.0.1"

          mentor_contract_version = latest_statement&.mentor_contract_version
          mentor_contract_version ||= "0.0.1"

          Finance::Statement::ECF.create!(
            name: statement_data.name,
            cpd_lead_provider:,
            cohort: statement_data.cohort,
            deadline_date: statement_data.deadline_date,
            payment_date: statement_data.payment_date,
            output_fee: statement_data.output_fee,
            type: class_for(statement_data, namespace: statement_data.type),
            contract_version:,
            mentor_contract_version:,
          )

          logger.info "CreateStatement: #{statement_data.cohort.start_year} cohort ECF statements for #{cpd_lead_provider.name} successfully created!"
        end
      end
    end

    def class_for(statment_data, namespace:)
      return namespace::Paid    if statment_data[:payment_date] < Date.current
      return namespace::Payable if Date.current.between?(statment_data[:deadline_date], statment_data[:payment_date])

      namespace
    end

    def statement_converter
      lambda do |value, field_info|
        case field_info.header
        when "type"
          Finance::Statement::ECF if value.downcase == "ecf"
        when "deadline_date", "payment_date"
          Date.parse(value)
        when "output_fee"
          ActiveModel::Type::Boolean.new.cast(value)
        when "cohort"
          Cohort.find_by!(start_year: value)
        else
          value
        end
      end
    end

    def check_headers!
      unless %w[type name cohort deadline_date payment_date output_fee].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(
        path_to_csv,
        headers: true,
        skip_blanks: true,
        converters: [statement_converter],
      )
    end

    def ecf_statements
      @ecf_statements ||= rows.map { |hash| OpenStruct.new(hash) }.select { |row| row.type == Finance::Statement::ECF }
    end

    def lead_providers_with_ecf_contracts_for(cohort:)
      @ecf_contracts ||= {}
      @ecf_contracts[cohort.id] ||= CallOffContract.includes(lead_provider: :cpd_lead_provider).where(cohort:).map(&:lead_provider)
    end
  end
end
