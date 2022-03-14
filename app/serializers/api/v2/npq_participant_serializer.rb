# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V2
    class NPQParticipantSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      set_type :'npq-participant'

      attributes :email, :full_name

      attribute(:teacher_reference_number) do |object|
        object.teacher_profile&.trn
      end

      attribute(:updated_at) do |object|
        object.updated_at.rfc3339
      end

      attribute(:npq_enrollments) do |object, params|
        scope = object.npq_profiles
        scope = scope.includes(:npq_course, :npq_application, schedule: [:cohort])

        if params[:cpd_lead_provider]
          scope = scope.joins(npq_application: { npq_lead_provider: [:cpd_lead_provider] })
          scope = scope.where(npq_applications: { npq_lead_providers: { cpd_lead_provider: params[:cpd_lead_provider] } })
        end

        scope.map do |profile|
          {
            course_identifier: profile.npq_course.identifier,
            schedule_identifier: profile.schedule.schedule_identifier,
            cohort: profile.schedule.cohort.start_year.to_s,
            npq_application_id: profile.npq_application.id,
            eligible_for_funding: profile.npq_application.eligible_for_funding,
            training_status: profile.training_status,
            school_urn: profile.school_urn,
          }
        end
      end
    end
  end
end
