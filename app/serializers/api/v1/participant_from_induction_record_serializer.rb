# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ParticipantFromInductionRecordSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      class << self
        def trn(profile)
          profile.teacher_profile.trn || profile.ecf_participant_validation_data&.trn
        end

        def validated_trn(profile)
          eligibility = profile.ecf_participant_eligibility
          eligibility.present? && !eligibility.different_trn_reason?
        end

        def eligible_for_funding?(profile)
          ecf_participant_eligibility = profile.ecf_participant_eligibility
          return if ecf_participant_eligibility.nil?
          return true if ecf_participant_eligibility.eligible_status?
          return false if ecf_participant_eligibility.ineligible_status?
        end
      end

      set_type :participant

      set_id :id do |induction_record|
        induction_record.participant_profile.participant_identity.user_id
      end

      attribute :email do |induction_record|
        induction_record.preferred_identity&.email ||
          induction_record.participant_profile.user.email
      end

      attribute :full_name do |induction_record|
        induction_record.participant_profile.user.full_name
      end

      attribute :mentor_id do |induction_record|
        if induction_record.participant_profile.ect?
          induction_record.mentor_profile&.participant_identity&.user_id
        end
      end

      attribute :school_urn do |induction_record|
        induction_record.induction_programme&.school_cohort&.school&.urn
      end

      attribute :participant_type do |induction_record|
        induction_record.participant_profile.participant_type
      end

      attribute :cohort do |induction_record|
        induction_record.induction_programme&.school_cohort&.cohort&.start_year&.to_s
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
        trn(induction_record.participant_profile)
      end

      attribute :teacher_reference_number_validated do |induction_record|
        if trn(induction_record.participant_profile).nil?
          nil
        else
          validated_trn(induction_record.participant_profile).present?
        end
      end

      attribute :eligible_for_funding do |induction_record|
        eligible_for_funding?(induction_record.participant_profile)
      end

      attribute :pupil_premium_uplift do |induction_record|
        induction_record.participant_profile.pupil_premium_uplift
      end

      attribute :sparsity_uplift do |induction_record|
        induction_record.participant_profile.sparsity_uplift
      end

      attribute :training_status, &:training_status

      attribute :schedule_identifier do |induction_record|
        induction_record.schedule&.schedule_identifier
      end

      attribute :updated_at do |induction_record|
        [
          induction_record.participant_profile.updated_at,
          induction_record.participant_profile.user.updated_at,
          induction_record.participant_profile.participant_identity.updated_at,
          induction_record.updated_at,
        ].max.rfc3339
      end
    end
  end
end
