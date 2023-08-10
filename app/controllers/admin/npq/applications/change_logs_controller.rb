# frozen_string_literal: true

module Admin::NPQ::Applications
  class ChangeLogsController < Admin::BaseController
    skip_after_action :verify_policy_scoped

    def show
      authorize NPQApplication

      @npq_application = NPQApplication.find(params[:application_id])

      @versions = (
        @npq_application.versions.where_attribute_changes("eligible_for_funding") +
        @npq_application.versions.where_attribute_changes("funding_eligiblity_status_code")
      ).compact.sort_by(&:created_at).uniq.reverse
    end
  end
end
