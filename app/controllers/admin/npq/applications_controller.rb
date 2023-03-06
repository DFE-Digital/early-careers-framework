# frozen_string_literal: true

module Admin
  module NPQ
    class ApplicationsController < Admin::BaseController
      skip_after_action :verify_policy_scoped, except: :index
      skip_after_action :verify_authorized

      def index
        query_string = params[:query]

        results = Admin::NPQApplications::ApplicationsSearch
          .new(policy_scope(NPQApplication), query_string:).call
        @pagy, @applications = pagy_array(results, page: params[:page], items: 20)
        @page = @pagy.page
        @total_pages = @pagy.pages
      end

      def show
        @application = NPQApplication.includes(:participant_identity)
                                     .joins({ participant_identity: :user })
                                     .find(params[:id])
      end
    end
  end
end
