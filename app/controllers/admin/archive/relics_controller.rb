# frozen_string_literal: true

module Admin
  module Archive
    class RelicsController < Admin::BaseController
      skip_after_action :verify_authorized, only: %i[index]
      skip_after_action :verify_policy_scoped, only: %i[show]
      before_action :set_relic, only: %i[show]

      def index
        search_term = params[:query]
        role        = params[:type]

        @relics = ::Archive::Search.call(policy_scope(::Archive::Relic), search_term:, role:)
      end

      def show
        @user = ::Archive::UserPresenter.new(@relic.data)
      end

    private

      def set_relic
        @relic = ::Archive::Relic.find(params[:id])
        authorize @relic
      end
    end
  end
end
