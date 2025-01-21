# frozen_string_literal: true

class CpdLeadProvider < ApplicationRecord
  has_paper_trail

  has_one :lead_provider
  has_many :participant_declarations
  has_many :statements, class_name: "Finance::Statement"
  has_many :ecf_statements, class_name: "Finance::Statement::ECF"

  validates :name, presence: { message: "Enter a name" }
end
