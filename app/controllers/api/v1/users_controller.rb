# frozen_string_literal: true

module Api
  module V1
    class Api::V1::UsersController < Api::ApiController
      def index
        render json: { users: User.all.as_json }
      end
    end
  end
end
