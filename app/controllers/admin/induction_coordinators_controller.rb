# frozen_string_literal: true

module Admin
  class InductionCoordinatorsController < Admin::BaseController
    skip_after_action :verify_authorized, only: %i[index new create advisory]
    skip_after_action :verify_policy_scoped, except: :index
    before_action :load_induction_coordinator, only: %i[edit update]

    def index
      @induction_coordinators = policy_scope(User).induction_coordinators
    end

    def advisory
      @school = School.last
    end

    def new
      # is admin only?
      @school = School.last # params[:school]
      @induction_coordinator = User.new
    end

    def create
      # is admin only?
      user = User.create!(user_params)
      school = School.last
      InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
        profile.update!(schools: [school])
      end
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

    def user_params
      params.require(:user).permit(:full_name, :email)
    end

    def load_induction_coordinator
      @induction_coordinator = User.find(params[:id])
      authorize @induction_coordinator
    end
  end
end
