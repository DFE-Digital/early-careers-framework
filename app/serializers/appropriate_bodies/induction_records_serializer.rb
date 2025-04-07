# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module AppropriateBodies
  class InductionRecordsSerializer
    include JSONAPI::Serializer
    include JSONAPI::Serializer::Instrumentation

    set_type :participant

    attribute :full_name do |induction_record|
      induction_record.user.full_name
    end

    attribute :trn do |induction_record|
      induction_record.participant_profile.teacher_profile.trn
    end

    attribute :school_urn do |induction_record|
      induction_record.school&.urn
    end

    attribute :status do |induction_record, params|
      participant_profile = induction_record.participant_profile
      StatusTags::AppropriateBodyParticipantStatusTag.new(params[:training_record_states][participant_profile.id]).label
    end

    attribute :induction_type

    attribute :induction_tutor do |induction_record|
      induction_record.school.contact_email
    end
  end
end
