# frozen_string_literal: true

module Api
  module V1
    module NPQ
      class ApplicationSynchronizationsController < ApiController
        before_action :set_npq_applications
        def index
          render json: serializer_class.new(@npq_applications).serializable_hash
        end

      private

        def serializer_class
          Api::V1::NPQ::ApplicationSynchronizationSerializer
        end

        def updated_applications
          NPQApplication.where("updated_at >= ?", 1.week.ago).select(:lead_provider_approval_status, :id, :participant_identity_id)
        end

        def applications_by_ids
          ecf_ids = params[:ecf_ids].split(',')
          remaining_applications_count = 1000 - NPQApplication.where("updated_at >= ?", 1.week.ago).count
          applications_to_fetch_count = [remaining_applications_count, NPQApplication.count].min
          if applications_to_fetch_count > 0
            NPQApplication.where(id: ecf_ids).limit(applications_to_fetch_count).select(:lead_provider_approval_status, :id, :participant_identity_id)
          end
        end

        # TODO: This needs to be optimized.
        # It will work fine for now because we are fetching records
        # that have been change within a week.
        def set_npq_applications
          @npq_applications = applications_by_ids + updated_applications
        end
      end
    end
  end
end
