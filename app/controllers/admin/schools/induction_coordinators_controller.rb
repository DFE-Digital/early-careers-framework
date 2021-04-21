# frozen_string_literal: true

module Admin
  class Schools::InductionCoordinatorsController < Admin::BaseController
    skip_after_action :verify_authorized, only: %i[new create]
    before_action :load_induction_coordinator, only: %i[new create]

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
