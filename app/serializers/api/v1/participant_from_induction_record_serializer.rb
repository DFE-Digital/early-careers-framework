# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ParticipantFromInductionRecordSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      class << self
        def active_participant_attribute(attr, &blk)
          attribute attr do |induction_record, params|
            if induction_record.participant_profile.active_record?
              if blk.parameters.count == 1
                blk.call(induction_record)
              else
                blk.call(induction_record, params)
              end
            end
          end
        end

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
        # NOTE: using this will retain the original ID exposed to provider
        induction_record.participant_profile.participant_identity.external_identifier
        # NOTE: use this instead to use new (de-duped) ID
        # induction_record.participant_profile.user.id
      end

      active_participant_attribute :email do |induction_record|
        # NOTE: using this will retain the original email exposed to provider
        induction_record.participant_profile.participant_identity.email
        # NOTE: use this instead to use new (de-duped) email
        # induction_record.participant_profile.user.email
      end

      active_participant_attribute :full_name do |induction_record|
        induction_record.participant_profile.user.full_name
      end

      active_participant_attribute :mentor_id do |induction_record|
        if induction_record.participant_profile.ect?
          induction_record.participant_profile.mentor&.id
        end
      end

      active_participant_attribute :school_urn do |induction_record|
        induction_record.participant_profile.school.urn
      end

      active_participant_attribute :participant_type do |induction_record|
        induction_record.participant_profile.participant_type
      end

      active_participant_attribute :cohort do |induction_record|
        induction_record.participant_profile.cohort.start_year.to_s
      end

      attribute :status do |induction_record|
        induction_record.participant_profile.status
      end

      active_participant_attribute :teacher_reference_number do |induction_record|
        trn(induction_record.participant_profile)
      end

      active_participant_attribute :teacher_reference_number_validated do |induction_record|
        if trn(induction_record.participant_profile).nil?
          nil
        else
          validated_trn(induction_record.participant_profile).present?
        end
      end

      active_participant_attribute :eligible_for_funding do |induction_record|
        eligible_for_funding?(induction_record.participant_profile)
      end

      active_participant_attribute :pupil_premium_uplift do |induction_record|
        induction_record.participant_profile.pupil_premium_uplift
      end

      active_participant_attribute :sparsity_uplift do |induction_record|
        induction_record.participant_profile.sparsity_uplift
      end

      active_participant_attribute :training_status do |induction_record|
        induction_record.participant_profile.training_status
      end

      active_participant_attribute :schedule_identifier do |induction_record|
        induction_record.schedule&.schedule_identifier
      end

      attribute :updated_at do |induction_record|
        induction_record.participant_profile.user.updated_at.rfc3339
      end
    end
  end
end
