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

    attribute :status do |induction_record|
      StatusTags::AppropriateBodyParticipantStatusTag.new(participant_profile: induction_record.participant_profile, induction_record:).label
    end

    attribute :induction_type do |induction_record|
      if induction_record.enrolled_in_cip?
        "CIP"
      elsif induction_record.enrolled_in_fip?
        "FIP"
      end
    end

    attribute :induction_tutor do |induction_record|
      induction_record.school.contact_email
    end
  end
end
