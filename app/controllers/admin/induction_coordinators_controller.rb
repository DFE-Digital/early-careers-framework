# frozen_string_literal: true

module Admin
  class InductionCoordinatorsController < Admin::BaseController
    skip_after_action :verify_policy_scoped
    before_action :load_induction_coordinator

    def edit
      authorize User
    end

    def update
      authorize User

      if @induction_coordinator.update(permitted_attributes(@induction_coordinator))
        redirect_to :admin_supplier_users, notice: "Changes saved successfully"
      else
        render :edit
      end
    end

  private

    def load_induction_coordinator
      @induction_coordinator = User.find(params[:id])
    end
  end
end
