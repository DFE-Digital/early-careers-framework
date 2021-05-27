# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::ApiController
      include ApiTokenAuthenticatable
      include Pagy::Backend

      def index
        render json: UserSerializer.new(paginate(users)).serializable_hash.to_json
      end

    private

      def updated_since
        params.dig(:filter, :updated_since)
      end

      def users
        users = User.all.includes(early_career_teacher_profile: [:core_induction_programme], mentor_profile: [:core_induction_programme])

        if updated_since.present?
          users = users.changed_since(updated_since)
        end

        users
      end

      def paginate(scope)
        _pagy, paginated_records = pagy(scope, items: per_page, page: page)

        paginated_records
      end

      def per_page
        params[:page] ||= {}

        [(params.dig(:page, :per_page) || default_per_page).to_i, max_per_page].min
      end

      def default_per_page
        100
      end

      def max_per_page
        100
      end

      def page
        params[:page] ||= {}
        (params.dig(:page, :page) || 1).to_i
      end
    end
  end
end
