# frozen_string_literal: true

class Importers::SeedStatements
  def call
    LeadProvider.includes(:cpd_lead_provider).each do |lead_provider|
      cpd_lead_provider = lead_provider.cpd_lead_provider

      ecf_statements.each do |statement_data|
        statement = Finance::Statement::ECF.find_or_create_by!(
          name: statement_data.name,
          cpd_lead_provider: cpd_lead_provider,
        )

        statement.update!(
          deadline_date: statement_data.deadline_date,
          payment_date: statement_data.payment_date,
        )
      end
    end

    NPQLeadProvider.includes(:cpd_lead_provider).each do |npq_lead_provider|
      cpd_lead_provider = npq_lead_provider.cpd_lead_provider

      npq_statements.each do |statement_data|
        statement = Finance::Statement::NPQ.find_or_create_by!(
          name: statement_data.name,
          cpd_lead_provider: cpd_lead_provider,
        )

        statement.update!(
          deadline_date: statement_data.deadline_date,
          payment_date: statement_data.payment_date,
        )
      end
    end
  end

private

  def ecf_statements
    [
      { name: "November 2021", deadline_date: Date.new(2021, 11, 30), payment_date: Date.new(2021, 11, 30) },
      { name: "January 2022", deadline_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28) },
      { name: "February 2022", deadline_date: Date.new(2022, 2, 28), payment_date: Date.new(2022, 3, 31) },
    ].map { |hash| OpenStruct.new(hash) }
  end

  def npq_statements
    [
      { name: "December 2021", deadline_date: Date.new(2021, 12, 25), payment_date: Date.new(2022, 1, 31) },
      { name: "January 2021", deadline_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28) },
    ].map { |hash| OpenStruct.new(hash) }
  end
end
