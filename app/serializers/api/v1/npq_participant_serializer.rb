# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class NPQParticipantSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      set_type :'npq-participant'

      attribute :participant_id
      attribute :email
      attribute :full_name

      attribute(:participant_id, &:id)

      attribute(:npq_courses) do |object, params|
        npq_profiles = npq_profiles(object, params)

        npq_profiles.map { |npq_profile| npq_profile.npq_application.npq_course.identifier }
      end

      attribute :funded_places, if: -> { FeatureFlag.active?(:npq_capping) } do |object, params|
        npq_profiles = npq_profiles(object, params)

        npq_profiles.map do |npq_profile|
          {
            "npq_course": npq_profile.npq_application.npq_course.identifier,
            "funded_place:": npq_profile.npq_application.funded_place,
            "npq_application_id": npq_profile.npq_application.id,
          }
        end
      end

      attribute(:teacher_reference_number) do |object|
        object.teacher_profile&.trn
      end

      attribute(:updated_at) do |object|
        object.updated_at.rfc3339
      end

      def self.npq_profiles(object, params)
        scope = object.npq_profiles
        scope = scope.includes(npq_application: [:npq_course])

        if params[:cpd_lead_provider]
          scope = scope.joins(npq_application: { npq_lead_provider: [:cpd_lead_provider] })
          scope = scope.where(npq_applications: { npq_lead_providers: { cpd_lead_provider: params[:cpd_lead_provider] } })
        else
          scope = ParticipantProfile::NPQ.none
        end
        scope
      end
    end
  end
end
