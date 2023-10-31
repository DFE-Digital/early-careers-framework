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

        # TODO: This needs to be optimized.
        # It will work fine for now because we are fetching records
        # that have been change within a week.
        # Added new piece of code for catered the nil values for record in npq
        # Remove this code once all application statuses have been migrated.
        def set_npq_applications
          ecf_ids = params[:ecf_ids].split(",")

          @npq_applications = NPQApplication
            .where(id: ecf_ids)
            .or(NPQApplication.where(updated_at: 1.week.ago..))
            .select(:lead_provider_approval_status, :id, :participant_identity_id)
        end
      end
    end
  end
end
