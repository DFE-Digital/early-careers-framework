# frozen_string_literal: true

module Finance
  class AddAnotherAdjustmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Rails.application.routes.url_helpers

    attribute :statement
    attribute :add_another

    validates_inclusion_of :add_another, in: %w[yes no]

    def redirect_to
      if add_another == "yes"
        new_finance_statement_adjustment_path(statement)
      elsif statement.ecf?
        finance_ecf_payment_breakdown_statement_path(statement.lead_provider, statement)
      elsif statement.npq?
        finance_npq_lead_provider_statement_path(statement.npq_lead_provider, statement)
      end
    end
  end
end
