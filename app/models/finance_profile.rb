# frozen_string_literal: true

class FinanceProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
end
