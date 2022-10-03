# frozen_string_literal: true

class Finance::Statement::NPQ::Paid < Finance::Statement::NPQ
  def open?
    false
  end

  def paid?
    true
  end
end
