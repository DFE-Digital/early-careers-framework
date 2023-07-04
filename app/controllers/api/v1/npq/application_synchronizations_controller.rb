# frozen_string_literal: true

module Api
  module V1
    module NPQ
      class ApplicationSynchronizationsController < ApiController
        before_action :set_npq_applications
        def index
          render json: ApplicationStatusQuery.new(@npq_applications).call
        end

      private

        # TODO: This needs to be optimized.
        # It will work fine for now because we are fetching records
        # that have been change within a week.
        def set_npq_applications
          @npq_applications = NPQApplication.where("updated_at >= ?", 1.week.ago).pluck(:lead_provider_approval_status, :id, :participant_identity_id)
        end
      end
    end
  end
end
