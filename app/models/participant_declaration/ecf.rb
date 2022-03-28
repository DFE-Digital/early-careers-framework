# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  include RecordDeclarations::ECF
  belongs_to :statement, optional: true, class_name: "Finance::Statement::ECF"
end
