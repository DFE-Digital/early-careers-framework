# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ParticipantFromQuerySerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      class << self
        def trn(record)
          record.teacher_profile_trn || record.ecf_participant_validation_data_trn
        end

        def validated_trn(record)
          eligibility = record.ecf_participant_eligibility_reason
          eligibility.present? && eligibility != "different_trn"
        end

        def eligible_for_funding?(record)
          ecf_participant_eligibility_status = record.ecf_participant_eligibility_status
          return if ecf_participant_eligibility_status.nil?
          return true if ecf_participant_eligibility_status == "eligible"
          return false if ecf_participant_eligibility_status == "ineligible"
        end
      end

      set_type :participant

      set_id :id do |induction_record|
        if FeatureFlag.active?(:external_identifier_to_user_id_lookup)
          induction_record.user_id
        else
          induction_record.external_identifier
        end
      end

      attribute :email do |induction_record|
        induction_record.preferred_identity_email ||
          induction_record.user_email
      end

      attribute :full_name, &:full_name

      attribute :mentor_id do |induction_record|
        if induction_record.participant_profile_type == "ParticipantProfile::ECT"
          induction_record.mentor_external_identifier
        end
      end

      attribute :school_urn, &:schools_urn

      attribute :participant_type do |induction_record|
        if induction_record.participant_profile_type == "ParticipantProfile::ECT"
          :ect
        else
          :mentor
        end
      end

      attribute :cohort do |induction_record|
        induction_record.start_year&.to_s
      end

      attribute :status do |induction_record|
        case induction_record.induction_status
        when "active", "completed", "leaving"
          "active"
        when "withdrawn", "changed"
          "withdrawn"
        end
      end

      attribute :teacher_reference_number do |induction_record|
        trn(induction_record)
      end

      attribute :teacher_reference_number_validated do |induction_record|
        if trn(induction_record).nil?
          nil
        else
          validated_trn(induction_record).present?
        end
      end

      attribute :eligible_for_funding do |induction_record|
        eligible_for_funding?(induction_record)
      end

      attribute :pupil_premium_uplift, &:pupil_premium_uplift

      attribute :sparsity_uplift, &:sparsity_uplift

      attribute :training_status, &:training_status

      attribute :schedule_identifier, &:schedule_identifier

      attribute :updated_at do |induction_record|
        [
          induction_record.participant_profile_updated_at,
          induction_record.user_updated_at,
          induction_record.participant_identity_updated_at,
          induction_record.updated_at,
        ].compact.max.rfc3339
      end
    end
  end
end
