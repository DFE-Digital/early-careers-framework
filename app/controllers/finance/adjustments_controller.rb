# frozen_string_literal: true

module Finance
  class AdjustmentsController < BaseController
    before_action :set_statement
    before_action :redirect_if_adjustment_not_editable
    before_action :set_adjustment, only: %i[edit update delete destroy]

    def index
      @adjustments = @statement.adjustments
      @add_another_form = Finance::AddAnotherAdjustmentForm.new(add_another_params.merge(statement: @statement))

      if @adjustments.empty?
        redirect_to statement_path
      end
    end

    def add_another
      index
      params[:added_new] = true

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

    def edit
      @adjustment = Finance::UpdateAdjustmentForm.new(adjustment: @adjustment, session:)
      @adjustment.form_step = params[:form_step]
    end

    def update
      @adjustment = Finance::UpdateAdjustmentForm.new(adjustment: @adjustment, session:)
      @adjustment.assign_attributes(adjustment_params)

      if @adjustment.save_step
        redirect_to @adjustment.redirect_to
      else
        render :new, status: :unprocessable_entity
      end
    end

    def delete; end

    def destroy
      @adjustment.destroy!
      redirect_to finance_statement_adjustments_path(@statement)
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

    def set_adjustment
      @adjustment = @statement.adjustments.find(params[:id])
    end

    def redirect_if_adjustment_not_editable
      return if @statement.adjustment_editable?

      redirect_to statement_path
    end

    def statement_path
      if @statement.ecf?
        finance_ecf_payment_breakdown_statement_path(@statement.lead_provider, @statement)
      elsif @statement.npq?
        finance_npq_lead_provider_statement_path(@statement.npq_lead_provider, @statement)
      end
    end

    helper_method :statement_path
  end
end
