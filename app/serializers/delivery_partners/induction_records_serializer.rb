# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module DeliveryPartners
  class InductionRecordsSerializer
    include JSONAPI::Serializer
    include JSONAPI::Serializer::Instrumentation

    set_type :participant

    attribute :full_name do |induction_record|
      induction_record.user.full_name
    end

    attribute :email_address do |induction_record|
      participant_profile = induction_record.participant_profile
      induction_record.preferred_identity&.email || participant_profile.user.email
    end

    attribute :trn do |induction_record|
      induction_record.participant_profile.teacher_profile.trn
    end

    attribute :role do |induction_record|
      induction_record.participant_profile.role
    end

    attribute :lead_provider do |induction_record|
      induction_record.induction_programme&.partnership&.lead_provider&.name
    end

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

    attribute :status do |induction_record, params|
      StatusTags::DeliveryPartnerParticipantStatusTag.new(params[:training_record_states][induction_record.participant_profile_id]).label
    end
  end
end
