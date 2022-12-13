# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  has_many :statements, class_name: "Finance::Statement::ECF", through: :statement_line_items

  def ecf?
    true
  end
end
