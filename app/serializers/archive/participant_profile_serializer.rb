# frozen_string_literal: true

module Archive
  class ParticipantProfileSerializer
    include JSONAPI::Serializer
    include ArchiveHelper

    set_id :id

    # if top level User isn't archived but profiles are
    # including User metadata to enable searching
    meta do |participant_profile|
      add_user_metadata(participant_profile.user)
    end

    attribute :type
    attribute :participant_identity_id
    attribute :sparsity_uplift
    attribute :pupil_premium_uplift
    attribute :schedule_id
    attribute :school_cohort_id
    attribute :teacher_profile_id
    attribute :status
    attribute :training_status
    attribute :induction_start_date
    attribute :induction_completion_date
    attribute :profile_duplicity
    attribute :notes
    attribute :created_at

    attribute :induction_record_ids do |participant_profile|
      participant_profile.induction_records.map do |induction_record|
        {
          id: induction_record.id,
        }
      end
    end
  end
end
