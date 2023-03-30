# frozen_string_literal: true

module Admin
  class ImpersonatesController < Admin::BaseController
    skip_after_action :verify_policy_scoped

    before_action :load_user, only: [:create]
    before_action :check_self_impersonation, only: [:create]
    before_action :check_admin_user_impersonation, only: [:create]
    before_action { authorize @user, policy_class: ImpersonationPolicy }

    def create
      impersonate_user(@user)

      redirect_to after_sign_in_path_for(@user)
    end

    def destroy
      stop_impersonating_user
      redirect_to after_sign_in_path_for(current_user)
    end

  private

    def load_user
      @user = User.find(params[:impersonated_user_id])
    end

    def check_self_impersonation
      if params[:impersonated_user_id] == current_user.id.to_s
        flash[:warning] = "You cannot impersonate yourself"
        redirect_to(after_sign_in_path_for(current_user))
      end
    end

    def check_admin_user_impersonation
      if @user.admin?
        flash[:warning] = "You cannot impersonate another admin user"
        redirect_to(after_sign_in_path_for(current_user))
      end
    end

    def pundit_user
      true_user
    end
  end
end
