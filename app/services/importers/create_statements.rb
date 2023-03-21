# frozen_string_literal: true

# This class provides a mechnism to import genesis statements
# It is not designed to keep statements in sync
# For that should be done by hand
# We only create/update version 0.0.1 for initial values
# Manually create new version of contract if there are changes

require "csv"

module Importers
  class CreateStatements
    def call
      LeadProvider.includes(:cpd_lead_provider).each do |lead_provider|
        cpd_lead_provider = lead_provider.cpd_lead_provider

        ecf_statements.each do |statement_data|
          statement = Finance::Statement::ECF.find_by(
            name: statement_data.name,
            cpd_lead_provider:,
            cohort: statement_data.cohort,
          )

          next if statement

          Finance::Statement::ECF.create!(
            name: statement_data.name,
            cpd_lead_provider:,
            cohort: statement_data.cohort,
            deadline_date: statement_data.deadline_date,
            payment_date: statement_data.payment_date,
            output_fee: statement_data.output_fee,
            type: class_for(statement_data, namespace: Finance::Statement::ECF),
            contract_version: "0.0.1",
          )
        end
      end

      NPQLeadProvider.includes(:cpd_lead_provider).each do |npq_lead_provider|
        cpd_lead_provider = npq_lead_provider.cpd_lead_provider

        npq_statements.each do |statement_data|
          statement = Finance::Statement::NPQ.find_by(
            name: statement_data.name,
            cpd_lead_provider:,
            cohort: statement_data.cohort,
          )

          next if statement

          Finance::Statement::NPQ.create!(
            name: statement_data.name,
            cpd_lead_provider:,
            deadline_date: statement_data.deadline_date,
            payment_date: statement_data.payment_date,
            cohort: statement_data.cohort,
            output_fee: statement_data.output_fee,
            type: class_for(statement_data, namespace: Finance::Statement::NPQ),
            contract_version: "0.0.1",
          )
        end
      end
    end

  private

    def class_for(statment_data, namespace:)
      return namespace::Paid    if statment_data[:payment_date] < Date.current
      return namespace::Payable if Date.current.between?(statment_data[:deadline_date], statment_data[:payment_date])

      namespace
    end

    def statement_converter
      lambda do |value, field_info|
        case field_info.header
        when "deadline_date", "payment_date"
          Date.parse(value)
        when "output_fee"
          ActiveModel::Type::Boolean.new.cast(value)
        when "cohort"
          Cohort.find_or_create_by!(start_year: value)
        else
          value
        end
      end
    end

    def ecf_statements
      @ecf_statements ||= CSV.read(
        Rails.root.join("db/data/statements/ecf.csv"),
        headers: true,
        skip_blanks: true,
        converters: [statement_converter],
      ).map { |hash| OpenStruct.new(hash) }
    end

    def npq_statements
      @npq_statements ||= CSV.read(
        Rails.root.join("db/data/statements/npq.csv"),
        headers: true,
        skip_blanks: true,
        converters: [statement_converter],
      ).map { |hash| OpenStruct.new(hash) }
    end
  end
end
