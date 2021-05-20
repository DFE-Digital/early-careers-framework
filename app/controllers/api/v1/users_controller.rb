# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::ApiController
      include ApiTokenAuthenticatable

      def index
        user_query = User.all.includes(:early_career_teacher_profile, :core_induction_programme)
        render json: UserSerializer.new(user_query).serializable_hash.to_json
      end
    end
  end
end
