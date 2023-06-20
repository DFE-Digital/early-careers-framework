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

    attribute :email_address do |induction_record|
      induction_record.preferred_identity&.email ||
        induction_record.user.email
    end

    attribute :trn do |induction_record|
      induction_record.participant_profile.teacher_profile.trn
    end

    attribute :role do |induction_record|
      induction_record.participant_profile.role
    end

    attribute :lead_provider, &:lead_provider_name

    attribute :delivery_partner, &:delivery_partner_name

    attribute :school do |induction_record|
      induction_record.school&.name
    end

    attribute :school_unique_reference_number do |induction_record|
      induction_record.school&.urn
    end

    attribute :academic_year do |induction_record|
      induction_record.cohort&.start_year
    end

    attribute :training_status, &:training_status

    attribute :status do |induction_record|
      StatusTags::AppropriateBodyParticipantStatusTag.new(participant_profile: induction_record.participant_profile, appropriate_body: induction_record.appropriate_body).label
    end
  end
end
