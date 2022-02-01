# frozen_string_literal: true

class Finance::Statement::ECF < Finance::Statement::Base
  belongs_to :lead_provider, optional: true
end
