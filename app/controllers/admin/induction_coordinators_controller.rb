# frozen_string_literal: true

module Admin
  class InductionCoordinatorsController < Admin::BaseController
    skip_after_action :verify_authorized, only: :index
    skip_after_action :verify_policy_scoped, except: :index
    before_action :load_induction_coordinator, only: %i[edit update]

    def index
      @induction_coordinators = policy_scope(User).induction_coordinators
    end

    def edit; end

    def update
      if @induction_coordinator.update(permitted_attributes(@induction_coordinator))
        redirect_to :admin_induction_coordinators, notice: "Changes saved successfully"
      else
        render :edit
      end
    end

  private

    def load_induction_coordinator
      @induction_coordinator = User.find(params[:id])
      authorize @induction_coordinator
    end
  end
end
