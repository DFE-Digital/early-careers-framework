# frozen_string_literal: true

module Finance
  module ECF
    class DuplicateSerializer
      include JSONAPI::Serializer

      set_id :id
      set_type :duplicate

      attribute :type, &:type
      attribute :sparsity_uplift, &:sparsity_uplift
      attribute :pupil_premium_uplift, &:pupil_premium_uplift
      attribute :status, &:status
      attribute :school_urn, &:school_urn
      attribute :school_ukprn, &:school_ukprn
      attribute :request_for_details_sent_at, &:request_for_details_sent_at
      attribute :training_status, &:training_status
      attribute :profile_duplicity, &:profile_duplicity
      attribute :notes, &:notes

      attribute :npq_course_id, &:npq_course_id
      attribute :schedule_id, &:schedule_id
      attribute :school_id, &:school_id
      attribute :core_induction_programme_id, &:core_induction_programme_id
      attribute :mentor_profile_id, &:mentor_profile_id
      attribute :school_cohort_id, &:school_cohort_id
      attribute :teacher_profile_id, &:teacher_profile_id
      attribute :participant_identity_id, &:participant_identity_id

      attribute :schedule_name do |object|
        object.schedule&.name
      end

      attribute :trn do |object|
        object.teacher_profile&.trn
      end

      attribute :external_identifier do |object|
        object.participant_identity&.external_identifier
      end

      attribute :email do |object|
        object.participant_identity&.email
      end

      attribute :cohort do |object|
        object&.school_cohort&.cohort&.display_name
      end

      attribute :created_at do |object|
        object.created_at.rfc3339
      end

      attribute :updated_at do |object|
        object.updated_at.rfc3339
      end

      attribute(:induction_records) do |object|
        object.induction_records.oldest_first.map do |induction_record|
          {
            id: induction_record.id,
            cohort: induction_record.induction_programme&.school_cohort&.cohort&.display_name,
            schedule_name: induction_record.schedule&.name,
            training_status: induction_record.training_status,
            start_date: induction_record.start_date&.rfc3339,
            end_date: induction_record.end_date&.rfc3339,
            induction_status: induction_record.induction_status,
            school_transfer: induction_record.school_transfer,
            preferred_identity_email: induction_record.preferred_identity&.email,
            preferred_identity_id: induction_record.preferred_identity_id,
            induction_programme_id: induction_record.induction_programme_id,
            mentor_profile_id: induction_record.mentor_profile_id,
            appropriate_body_id: induction_record.appropriate_body_id,
            created_at: induction_record.created_at.rfc3339,
            updated_at: induction_record.updated_at.rfc3339,
          }
        end
      end

      attribute(:participant_declarations) do |object|
        object.participant_declarations.map do |participant_declaration|
          {
            id: participant_declaration.id,
            declaration_type: participant_declaration.declaration_type,
            declaration_date: participant_declaration.declaration_date&.rfc3339,
            course_identifier: participant_declaration.course_identifier,
            evidence_held: participant_declaration.evidence_held,
            type: participant_declaration.type,
            cpd_lead_provider: participant_declaration.cpd_lead_provider&.name,
            state: participant_declaration.state,
            superseded_by_id: participant_declaration.superseded_by_id,
            sparsity_uplift: participant_declaration.sparsity_uplift,
            pupil_premium_uplift: participant_declaration.pupil_premium_uplift,
            delivery_partner_name: participant_declaration.delivery_partner&.name,
            created_at: participant_declaration.created_at.rfc3339,
            updated_at: participant_declaration.updated_at.rfc3339,
          }
        end
      end

      attribute(:participant_profile_states) do |object|
        object.participant_profile_states.map do |participant_profile_state|
          {
            id: participant_profile_state.id,
            reason: participant_profile_state.reason,
            state: participant_profile_state.state,
            created_at: participant_profile_state.created_at.rfc3339,
            updated_at: participant_profile_state.updated_at.rfc3339,
          }
        end
      end

      attribute(:participant_validation_data) do |object|
        participant_validation_data = object.ecf_participant_validation_data

        {
          id: participant_validation_data&.id,
          full_name: participant_validation_data&.full_name,
          date_of_birth: participant_validation_data&.date_of_birth&.rfc3339,
          trn: participant_validation_data&.trn,
          nino: participant_validation_data&.nino,
          api_failure: participant_validation_data&.api_failure,
          created_at: participant_validation_data&.created_at&.rfc3339,
          updated_at: participant_validation_data&.updated_at&.rfc3339,
        }
      end

      attribute(:validation_decisions) do |object|
        object.validation_decisions.map do |validation_decision|
          {
            id: validation_decision.id,
            validation_step: validation_decision.validation_step,
            approved: validation_decision.approved,
            note: validation_decision.note,
            created_at: validation_decision.created_at.rfc3339,
            updated_at: validation_decision.updated_at.rfc3339,
          }
        end
      end

      attribute(:participant_eligibility) do |object|
        ecf_participant_eligibility = object.ecf_participant_eligibility

        {
          id: ecf_participant_eligibility&.id,
          qts: ecf_participant_eligibility&.qts,
          active_flags: ecf_participant_eligibility&.active_flags,
          previous_participation: ecf_participant_eligibility&.previous_participation,
          previous_induction: ecf_participant_eligibility&.previous_induction,
          manually_validated: ecf_participant_eligibility&.manually_validated,
          status: ecf_participant_eligibility&.status,
          reason: ecf_participant_eligibility&.reason,
          different_trn: ecf_participant_eligibility&.different_trn,
          no_induction: ecf_participant_eligibility&.no_induction,
          exempt_from_induction: ecf_participant_eligibility&.exempt_from_induction,
          created_at: ecf_participant_eligibility&.created_at&.rfc3339,
          updated_at: ecf_participant_eligibility&.updated_at&.rfc3339,
        }
      end

      attribute(:participant_profile_schedules) do |object|
        object.participant_profile_schedules.map do |participant_profile_schedule|
          {
            id: participant_profile_schedule.id,
            schedule_id: participant_profile_schedule.schedule_id,
            created_at: participant_profile_schedule.created_at.rfc3339,
            updated_at: participant_profile_schedule.updated_at.rfc3339,
          }
        end
      end
    end
  end
end
