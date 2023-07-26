# frozen_string_literal: true

module Finance
  class CreateAdjustmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Rails.application.routes.url_helpers

    attribute :session
    attribute :statement
    attribute :payment_type
    attribute :amount, :float
    attribute :form_step

    validates :payment_type, presence: true, if: :validate_payment_type?
    validates :amount, numericality: { other_than: 0.0 }, if: :validate_amount?

    def initialize(*)
      super
      assign_attributes(fetch_values)
    end

    def save_step
      return false unless valid?

      case form_step
      when "step1"
        save_value(:payment_type, payment_type)
      when "step2"
        save_value(:amount, amount)
      when "confirm"
        statement.adjustments.create!(fetch_values)
        clear_values
      end

      true
    end

    def redirect_to
      case form_step
      when "step1"
        new_finance_statement_adjustment_path(statement, form_step: "step2")
      when "step2"
        new_finance_statement_adjustment_path(statement, form_step: "confirm")
      when "confirm"
        finance_statement_adjustments_path(statement)
      end
    end

    def back_link
      case form_step
      when "step1"
        if statement.ecf?
          finance_ecf_payment_breakdown_statement_path(statement.lead_provider, statement)
        elsif statement.npq?
          finance_npq_lead_provider_statement_path(statement.npq_lead_provider, statement)
        end
      when "step2"
        new_finance_statement_adjustment_path(statement, form_step: "step1")
      when "confirm"
        new_finance_statement_adjustment_path(statement, form_step: "step2")
      end
    end

    def form_step
      val = attribute("form_step")
      if %w[step1 step2 confirm].include?(val)
        val
      else
        "step1"
      end
    end

  private

    def validate_payment_type?
      %w[step1 confirm].include?(form_step)
    end

    def validate_amount?
      %w[step2 confirm].include?(form_step)
    end

    def clear_values
      session.delete(key_name)
    end

    def fetch_values
      return {} unless statement

      (session[key_name] || {}).slice(:payment_type, :amount)
    end

    def save_value(key, val)
      session[key_name] = fetch_values.merge({ key => val })
    end

    def key_name
      :"create_adjustment_form_#{statement.id}"
    end
  end
end
