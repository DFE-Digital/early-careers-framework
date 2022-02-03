# frozen_string_literal: true

class Migrators::DeclarationsToStatement
  def call
    assign_ecf_declarations
    assign_npq_declarations
  end

private

  def assign_ecf_declarations
    CpdLeadProvider.all.each do |cpd_lead_provider|
      statement = Finance::Statement::ECF.find_by(name: "November 2021", cpd_lead_provider: cpd_lead_provider)
      ParticipantDeclaration::ECF.where(state: "paid", cpd_lead_provider: cpd_lead_provider).update(statement: statement)

      statement = Finance::Statement::ECF.find_by(name: "January 2022", cpd_lead_provider: cpd_lead_provider)
      ParticipantDeclaration::ECF.where(state: "payable", cpd_lead_provider: cpd_lead_provider).update(statement: statement)
    end
  end

  def assign_npq_declarations
    CpdLeadProvider.all.each do |cpd_lead_provider|
      statement = Finance::Statement::NPQ.find_by(name: "December 2021", cpd_lead_provider: cpd_lead_provider)
      ParticipantDeclaration::NPQ.where(state: "payable", cpd_lead_provider: cpd_lead_provider).update(statement: statement)
    end
  end
end
