# frozen_string_literal: true

class Finance::Statement::NPQ::Paid < Finance::Statement::NPQ
  has_many :participant_declarations, -> { paid }, foreign_key: :statement_id

  def open?
    false
  end
end
