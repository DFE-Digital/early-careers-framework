# frozen_string_literal: true

class Finance::Statement::ECF::Paid < Finance::Statement::ECF
  def open?
    false
  end

  def paid?
    true
  end
end
