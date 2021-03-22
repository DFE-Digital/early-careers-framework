# frozen_string_literal: true

class Partnership < ApplicationRecord
  belongs_to :school
  belongs_to :lead_provider
  belongs_to :cohort

  has_paper_trail
end
