# frozen_string_literal: true

module Api
  module V1
    module NPQ
      class UsersController < ApiController
        def create
          creation_response = ::NPQ::Users::FindOrCreateBy.new(params: find_or_create_params).call

          if creation_response.user.present?
            hash = Api::V1::UserSerializer.new(creation_response.user).serializable_hash
            status_code = creation_response.new_user ? :created : :ok

            render json: hash, status: status_code
          else
            errors = [
              creation_response.errors,
              creation_response.error,
            ].flatten.compact

            hash = {
              errors: errors.map do |error|
                {
                  status: "401",
                  title: error.attribute,
                  detail: error.message,
                }
              end,
            }

            render json: hash, status: :unauthorized
          end
        end

      private

        def find_or_create_params
          params.require(:data).require(:attributes).permit(:email, :get_an_identity_id, :full_name)
        end
      end
    end
  end
end
