# frozen_string_literal: true

class Importers::StatementLineItems
  def call
    declarations.find_each do |declaration|
      Finance::StatementLineItem.find_or_create_by!(
        statement: declaration.statement,
        participant_declaration: declaration,
        state: declaration.state,
      )
    end
  end

private

  def declarations
    ParticipantDeclaration
      .where("statement_id is not null")
      .includes(:statement)
  end
end
