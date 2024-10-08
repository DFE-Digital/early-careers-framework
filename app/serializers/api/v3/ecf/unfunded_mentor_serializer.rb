# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    module ECF
      class UnfundedMentorSerializer
        include JSONAPI::Serializer
        include JSONAPI::Serializer::Instrumentation

        set_id :id, &:user_id
        set_type :'unfunded-mentor'

        attribute :full_name, &:full_name

        attribute :email do |user|
          user.preferred_identity_email || user.user_email
        end

        attribute :teacher_reference_number do |user|
          user.teacher_profile_trn.presence || user.ecf_participant_validation_data_trn
        end

        attribute :created_at do |user|
          user.user_created_at.rfc3339
        end

        attribute :updated_at do |user|
          user.user_updated_at.rfc3339
        end
      end
    end
  end
end
