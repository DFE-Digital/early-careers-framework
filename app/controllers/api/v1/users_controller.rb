# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::ApiController
      def index
        render json: { users: User.all.as_json(only: %i[id email full_name]) }
      end
    end
  end
end
