# frozen_string_literal: true

# Enable mentor funding and detailed evidence types for the 2025 cohort.
cohort_2025 = Cohort.find_by(start_year: 2025)
cohort_2025.update!(mentor_funding: true, detailed_evidence_types: true)

# Fix statements in finance dashboard.
all_statements = Finance::Statement::ECF.includes(:cohort).order(:payment_date).pluck(:name, :payment_date, :deadline_date).uniq

ActiveRecord::Base.transaction do
  all_statements.each do |(name, payment_date, deadline_date)|
    LeadProvider.find_each do |lead_provider|
      Cohort.find_each do |cohort|
        cpd_lead_provider = lead_provider.cpd_lead_provider
        existing_statement = lead_provider.statements.find_by(cohort:, name:)

        next if existing_statement

        FactoryBot.create(:ecf_statement, cpd_lead_provider:, cohort:, name:, payment_date:, deadline_date:)
      end
    end
  end
end

# Ensure all statements have call off contracts
Finance::Statement::ECF.find_each do |statement|
  cohort = statement.cohort
  lead_provider = statement.lead_provider
  version = statement.contract_version
  existing_contract = CallOffContract.find_by(version:, cohort:, lead_provider:)

  FactoryBot.create(:call_off_contract, version:, cohort:, lead_provider:) unless existing_contract

  existing_mentor_contract = MentorCallOffContract.find_by(version:, cohort:, lead_provider:)

  FactoryBot.create(:mentor_call_off_contract, version:, cohort:, lead_provider:) unless existing_mentor_contract
end
