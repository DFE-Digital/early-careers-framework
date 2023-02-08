# frozen_string_literal: true

module Api
  module V1
    module NPQ
      class UsersController < ApiController
        def show
          @user = Identity.find_user_by(id: params[:id])

          if @user.present?
            render_user(user: @user, status: :ok)
          else
            render json: { error: "User not found" }, status: :not_found
          end
        end

        def create
          creation_response = ::NPQ::Users::FindOrCreateBy.new(params: find_or_create_params).call

          if creation_response.success
            render_user(
              user: creation_response.user,
              status: creation_response.new_user ? :created : :ok,
            )
          else
            render_errors(errors: creation_response.errors)
          end
        end

        def update
          @user = Identity.find_user_by(id: params[:id])

          if @user.update(update_params)
            render_user(user: @user, status: :ok)
          else
            render_errors(errors: @user.errors)
          end
        end

      private

        def render_user(user:, status: :ok)
          serialized_user = Api::V1::NPQ::UserSerializer.new(user).serializable_hash

          render json: serialized_user, status:
        end

        def render_errors(errors:)
          hash = {
            errors: errors.map do |error|
              {
                title: error.attribute,
                detail: error.message,
              }
            end,
          }

          render json: hash, status: :bad_request
        end

        def find_or_create_params
          params.require(:data).require(:attributes).permit(:email, :get_an_identity_id, :full_name)
        end

        def update_params
          params.require(:data).require(:attributes).permit(:get_an_identity_id)
        end
      end
    end
  end
end
