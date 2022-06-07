# frozen_string_literal: true

class Finance::Statement::NPQ::Payable < Finance::Statement::NPQ
  def open?
    false
  end
end
