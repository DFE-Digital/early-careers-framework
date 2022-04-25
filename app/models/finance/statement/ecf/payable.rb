# frozen_string_literal: true

class Finance::Statement::ECF::Payable < Finance::Statement::ECF
  has_many :participant_declarations, -> { payable }, foreign_key: :statement_id

  def open?
    false
  end
end
