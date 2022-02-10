# frozen_string_literal: true

class Finance::Statement < ApplicationRecord
  include FinanceHelper

  self.table_name = "statements"

  belongs_to :cpd_lead_provider

  has_many :participant_declarations
end
