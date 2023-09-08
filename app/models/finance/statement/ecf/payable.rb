# frozen_string_literal: true

class Finance::Statement::ECF::Payable < Finance::Statement::ECF
  def open?
    false
  end

  def payable?
    true
  end
end
