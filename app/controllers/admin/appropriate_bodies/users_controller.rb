# frozen_string_literal: true

module Admin
  module AppropriateBodies
    class UsersController < Admin::BaseController
      skip_after_action :verify_authorized, only: :index
      skip_after_action :verify_policy_scoped, except: :index
      before_action :set_appropriate_body_profile_and_authorize, only: %i[edit update delete destroy]

      def index
        authorize AppropriateBodyProfile
        scoped = policy_scope(AppropriateBodyProfile).includes(:user).order("users.full_name asc")
        @pagy, @appropriate_body_profiles = pagy(scoped, page: params[:page], items: 20)
      end

      def new
        authorize AppropriateBodyProfile
        @appropriate_bodies_user_form = ::AppropriateBodies::CreateUserForm.new
      end

      def create
        authorize AppropriateBodyProfile
        @appropriate_bodies_user_form = ::AppropriateBodies::CreateUserForm.new(permitted_params)

        if @appropriate_bodies_user_form.save
          set_success_message(content: "Appropriate body user successfully added.", title: "Success")
          redirect_to admin_appropriate_bodies_users_path
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @appropriate_bodies_user_form = ::AppropriateBodies::UpdateUserForm.new(appropriate_body_profile: @appropriate_body_profile)
      end

      def update
        @appropriate_bodies_user_form = ::AppropriateBodies::UpdateUserForm.new(appropriate_body_profile: @appropriate_body_profile)

        if @appropriate_bodies_user_form.update(permitted_params)
          set_success_message(content: "Changes saved successfully.", title: "Success")
          redirect_to admin_appropriate_bodies_users_path
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def delete; end

      def destroy
        @appropriate_body_profile.destroy!
        set_success_message(content: "Appropriate body user deleted.", title: "Success")
        redirect_to admin_appropriate_bodies_users_path
      end

    private

      def permitted_params
        params.require(:appropriate_bodies_user_form).permit(
          :appropriate_body_id,
          :full_name,
          :email,
        )
      end

      def set_appropriate_body_profile_and_authorize
        @appropriate_body_profile = AppropriateBodyProfile.find(params[:id])
        authorize @appropriate_body_profile
      end
    end
  end
end
