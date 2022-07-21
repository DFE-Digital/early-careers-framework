# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ParticipantSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      class << self
        def induction_record(profile)
          if profile.active?
            profile.current_induction_record
          else
            profile.induction_records.latest
          end
        end

        def active_participant_attribute(attr, &blk)
          attribute attr do |profile, params|
            if profile.active?
              if blk.parameters.count == 1
                blk.call(profile)
              else
                blk.call(profile, params)
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

      set_id :id do |profile|
        # NOTE: using this will retain the original ID exposed to provider
        profile.participant_identity.external_identifier
        # NOTE: use this instead to use new (de-duped) ID
        # profile.user.id
      end

      active_participant_attribute :email do |profile|
        # NOTE: using this will retain the original email exposed to provider
        profile.participant_identity.email
        # NOTE: use this instead to use new (de-duped) email
        # profile.user.email
      end

      attribute :full_name do |profile|
        profile.user.full_name
      end

      attribute :mentor_id do |profile, params|
        if params[:mentor_ids].present?
          params[:mentor_ids][profile.id]
        elsif profile.ect?
          profile.mentor&.id
        end
      end

      attribute :school_urn do |profile|
        induction_record(profile).school.urn
      end

      attribute :participant_type

      attribute :cohort do |profile|
        profile.cohort.start_year.to_s
      end

      attribute :status do |profile|
        case induction_record(profile).induction_status
        when "active", "completed", "leaving"
          "active"
        when "withdrawn", "changed"
          "withdrawn"
        end
      end

      attribute :teacher_reference_number do |profile|
        trn(profile)
      end

      attribute :teacher_reference_number_validated do |profile|
        trn(profile).nil? ? nil : validated_trn(profile).present?
      end

      attribute :eligible_for_funding do |profile|
        eligible_for_funding?(profile)
      end

      attribute :pupil_premium_uplift
      attribute :sparsity_uplift

      attribute :training_status do |profile|
        induction_record(profile).training_status
      end

      attribute :schedule_identifier do |profile|
        profile.schedule&.schedule_identifier
      end

      attribute :updated_at do |profile|
        profile.user.updated_at.rfc3339
      end
    end
  end
end
