# frozen_string_literal: true

module Admin::NPQ::Applications
  class ChangeLogsController < Admin::BaseController
    skip_after_action :verify_policy_scoped

    def show
      authorize NPQApplication

      @npq_application = NPQApplication.find(params[:application_id])
      @versions = @npq_application.change_logs
    end
  end
end
