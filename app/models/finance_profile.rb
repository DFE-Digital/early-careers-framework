# frozen_string_literal: true

class FinanceProfile < ApplicationRecord
  has_paper_trail

  ROLES = %w[
    commercial_user
    product_team_user
    support_user
    provider_user
  ].freeze

  belongs_to :user
  belongs_to :lead_provider, optional: true

  validates :role, inclusion: { in: ROLES, message: "is not a valid role" }, allow_blank: true

  def commercial_user?
    role == "commercial_user"
  end

  def product_team_user?
    role == "product_team_user"
  end

  def support_user?
    role == "support_user"
  end

  def provider_user?
    role == "provider_user"
  end
end
