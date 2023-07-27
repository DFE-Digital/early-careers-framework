# frozen_string_literal: true

module Finance
  class UpdateAdjustmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Rails.application.routes.url_helpers

    attribute :session
    attribute :adjustment
    attribute :payment_type
    attribute :amount, :float
    attribute :form_step

    validates :payment_type, presence: true, if: :validate_payment_type?
    validates :amount, numericality: { other_than: 0.0 }, if: :validate_amount?

    delegate :id, :statement, to: :adjustment

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
        adjustment.update!(fetch_values)
        clear_values
      end

      true
    end

    def redirect_to
      case form_step
      when "step1"
        edit_finance_statement_adjustment_path(statement, adjustment, form_step: "confirm")
      when "step2"
        edit_finance_statement_adjustment_path(statement, adjustment, form_step: "confirm")
      when "confirm"
        finance_statement_adjustments_path(statement)
      end
    end

    def back_link
      case form_step
      when "step1"
        edit_finance_statement_adjustment_path(statement, adjustment, form_step: "confirm")
      when "step2"
        edit_finance_statement_adjustment_path(statement, adjustment, form_step: "confirm")
      when "confirm"
        finance_statement_adjustments_path(statement)
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
      cached_vals = (session[key_name] || {}).slice(:payment_type, :amount)
      {
        payment_type: adjustment.payment_type,
        amount: adjustment.amount,
      }.merge(cached_vals)
    end

    def save_value(key, val)
      session[key_name] = fetch_values.merge({ key => val })
    end

    def key_name
      :"update_adjustment_form_#{adjustment.id}"
    end
  end
end
