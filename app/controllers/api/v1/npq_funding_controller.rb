# frozen_string_literal: true

module Api
  module V1
    class NPQFundingController < Api::ApiController
      include ApiTokenAuthenticatable

      def show
        render json: service.call
      end

    private

      def service
        @service ||= ::NPQ::FundingEligibility.new(
          trn: params[:trn],
          npq_course_identifier: params[:npq_course_identifier],
        )
      end

      def access_scope
        ApiToken.where(private_api_access: true)
      end
    end
  end
end
