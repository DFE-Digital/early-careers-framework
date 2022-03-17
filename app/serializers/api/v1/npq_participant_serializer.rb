# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class NPQParticipantSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      class << self
        def active_participant_attribute(attr, &blk)
          attribute attr do |user, params|
            unless NPQ::IsUserWithdrawn.new(user: user, cpd_lead_provider: params[:cpd_lead_provider]).call
              blk.call(user)
            end
          end
        end
      end

      set_id :id
      set_type :'npq-participant'

      attribute :participant_id

      active_participant_attribute :email, &:email

      attribute :full_name

      attribute(:participant_id, &:id)

      attribute(:npq_courses) do |object, params|
        scope = object.npq_profiles
        scope = scope.includes(npq_application: [:npq_course])

        if params[:cpd_lead_provider]
          scope = scope.joins(npq_application: { npq_lead_provider: [:cpd_lead_provider] })
          scope = scope.where(npq_applications: { npq_lead_providers: { cpd_lead_provider: params[:cpd_lead_provider] } })
        else
          scope = ParticipantProfile::NPQ.none
        end

        scope.map { |npq_profile| npq_profile.npq_application.npq_course.identifier }
      end

      attribute(:teacher_reference_number) do |object|
        object.teacher_profile&.trn
      end

      attribute(:updated_at) do |object|
        object.updated_at.rfc3339
      end
    end
  end
end
