# frozen_string_literal: true

module Finance
  class AdjustmentsController < BaseController
    before_action :set_statement
    before_action :redirect_if_adjustment_not_editable

    def index
      @adjustments = @statement.adjustments
      @add_another_form = Finance::AddAnotherAdjustmentForm.new(add_another_params.merge(statement: @statement))

      if @adjustments.empty?
        redirect_to action: :new
      end
    end

    def add_another
      index

      if @add_another_form.valid?
        redirect_to @add_another_form.redirect_to
      else
        render :index, status: :unprocessable_entity
      end
    end

    def new
      @adjustment = Finance::CreateAdjustmentForm.new(statement: @statement, session:)
      @adjustment.form_step = params[:form_step]
    end

    def create
      @adjustment = Finance::CreateAdjustmentForm.new(statement: @statement, session:)
      @adjustment.assign_attributes(adjustment_params)

      if @adjustment.save_step
        redirect_to @adjustment.redirect_to
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def adjustment_params
      params.permit(
        finance_adjustment: %i[payment_type amount form_step],
      )[:finance_adjustment] || {}
    end

    def add_another_params
      params.permit(
        add_another_form: [:add_another],
      )[:add_another_form] || {}
    end

    def set_statement
      @statement = Finance::Statement.find(params[:statement_id])
    end

    def redirect_if_adjustment_not_editable
      return if @statement.adjustment_editable?

      if @statement.ecf?
        redirect_to finance_ecf_payment_breakdown_statement_path(@statement.lead_provider, @statement)
      elsif @statement.npq?
        redirect_to finance_npq_lead_provider_statement_path(@statement.npq_lead_provider, @statement)
      end
    end
  end
end
