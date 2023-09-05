# frozen_string_literal: true

module Archive
  class ParticipantProfileSerializer
    include JSONAPI::Serializer

    set_id :id

    meta do |profile|
      user = profile.user
      {
        display_name: user.full_name,
        search_terms: [
          user.id,
          user.full_name,
          user.email,
          user.teacher_profile&.trn,
        ].compact
      }
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
