# frozen_string_literal: true

module Api
  module V1
    module NPQ
      class PreviousFundingsController < ApiController
        before_action :ensure_identifier_present, only: :show
        before_action :ensure_npq_course_present, only: :show

        def show
          render json: service.call
        end

      private

        def trn
          params[:trn]
        end

        def get_an_identity_id
          params[:get_an_identity_id]
        end

        def npq_course
          params[:npq_course_identifier]
        end

        def ensure_identifier_present
          return if trn.present? || get_an_identity_id.present?

          error_body = { error: "No identifier provided. Valid identifier params: trn or get_an_identity_id" }
          render json: error_body, status: :bad_request
        end

        def ensure_npq_course_present
          return if npq_course.present?

          error_body = { error: "No npq_course_identifier provided" }
          render json: error_body, status: :bad_request
        end

        def service
          @service ||= ::NPQ::FundingEligibility.new(
            trn:,
            get_an_identity_id:,
            npq_course_identifier: npq_course,
          )
        end
      end
    end
  end
end
