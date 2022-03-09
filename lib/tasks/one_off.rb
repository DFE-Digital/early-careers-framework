namespace :one_off do
  desc "migrate statements to payable"
  task migrate_statement_to_payable: :environment do
    Finance::Statement::NPQ
      .joins(:participant_declarations)
      .where(participant_declarations: { state: "payable" })
      .distinct
      .update_all(type: "Finance::Statement::NPQ::Payable")
    end
  end
end
