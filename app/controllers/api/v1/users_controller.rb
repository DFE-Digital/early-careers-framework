# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter

      def index
        render json: UserSerializer.new(paginate(users)).serializable_hash.to_json
      end

      def create
        user = User.find_by(email: params[:data][:attributes][:email])

        if user.present?
          user.errors.add(:email, :taken)

          hash = {
            errors: [{
              status: "409",
              title: user.errors.full_messages.join(", "),
            }],
          }

          render json: hash, status: :conflict and return
        end

        user = User.create!(
          email: params[:data][:attributes][:email],
          full_name: params[:data][:attributes][:full_name],
        )

        hash = UserSerializer.new(user).serializable_hash

        render json: hash, status: :created
      end

    private

      def access_scope
        ApiToken.where(private_api_access: true)
      end

      def email
        filter[:email]
      end

      def users
        users = User.all
        users = users.changed_since(updated_since) if updated_since.present?
        users = users.where(email: email) if email.present?
        users
      end
    end
  end
end
